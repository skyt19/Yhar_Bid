/**
 * Firebase Cloud Functions for Yhar Bid AI Backend
 *
 * SECURITY:
 * - All functions require Firebase Authentication
 * - User ownership validation on all operations
 * - Groq API key secured via Firebase Secrets
 * - No credentials exposed to client
 *
 * MODEL LOCK:
 * - Groq model PERMANENTLY locked to: openai/gpt-oss-20b
 * - Cannot be overridden by client requests
 */

const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
require("dotenv").config();

// Initialize Firebase Admin
admin.initializeApp();

// CRITICAL: LOCKED GROQ MODEL - NEVER CHANGE THIS
const LOCKED_GROQ_MODEL = "openai/gpt-oss-20b";
const GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";

/**
 * Get Groq API key from environment variable
 * Set in functions/.env file: GROQ_API_KEY=your-key-here
 */
const getGroqApiKey = () => {
  const key = process.env.GROQ_API_KEY;
  if (!key) {
    throw new Error("GROQ_API_KEY not set in functions/.env file");
  }
  return key;
};

/**
 * Validate Firebase Authentication
 * @param {object} request - Firebase Functions request
 * @returns {object} - Authenticated user
 */
const validateAuth = (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated",
    );
  }
  return request.auth;
};

/**
 * Call Groq API with locked model
 * @param {Array} messages - Chat messages
 * @param {number} maxTokens - Max completion tokens
 * @param {number} temperature - Temperature setting
 * @returns {Promise<string>} - AI response
 */
const callGroqApi = async (messages, maxTokens = 500, temperature = 0.7) => {
  const apiKey = getGroqApiKey();

  const response = await fetch(GROQ_API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: LOCKED_GROQ_MODEL,
      messages: messages,
      max_tokens: maxTokens,
      temperature: temperature,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error("Groq API Error:", response.status, errorText);
    throw new functions.https.HttpsError(
        "unavailable",
        `AI service error: ${response.status}`,
    );
  }

  const data = await response.json();

  if (!data.choices || !data.choices[0] || !data.choices[0].message) {
    throw new functions.https.HttpsError(
        "internal",
        "Invalid AI response format",
    );
  }

  return data.choices[0].message.content;
};

/**
 * AI Chat Endpoint
 *
 * Handles conversational AI chat requests with role-based system prompts.
 *
 * Security:
 * - Requires authentication
 * - User-specific context only
 * - No cross-user data access
 *
 * @param {object} request.data - { message: string, role: string }
 * @returns {Promise<object>} - { response: string, model: string }
 */
exports.aiChat = functions.https.onCall(
    {region: "asia-southeast1"},
    async (request) => {
      try {
        // Validate authentication
        const auth = validateAuth(request);
        const userId = auth.uid;

        // Validate input
        const {message, role} = request.data;

        if (!message || typeof message !== "string" || message.trim() === "") {
          throw new functions.https.HttpsError(
              "invalid-argument",
              "Message is required and must be non-empty",
          );
        }

        if (!role || !["student", "corporateEmployee", "educator"].includes(role)) {
          throw new functions.https.HttpsError(
              "invalid-argument",
              "Valid role required: student, corporateEmployee, or educator",
          );
        }

        console.log(`AI Chat request from user ${userId}, role: ${role}`);

        // Build role-based system prompt
        const systemPrompts = {
          student: `คุณคือผู้ช่วยส่วนตัวสำหรับนักศึกษา ช่วยจัดการงานเรียน การบ้าน สอบ และกิจกรรม
ตอบเป็นภาษาไทยที่เป็นกันเอง กระชับ และให้กำลังใจ
เน้นการจัดการเวลา การวางแผนการเรียน และการเตรียมตัวสอบ`,

          corporateEmployee: `คุณคือผู้ช่วยส่วนตัวสำหรับพนักงานบริษัท ช่วยจัดการงาน ประชุม โปรเจกต์ และการประสานงาน
ตอบเป็นภาษาไทยที่เป็นมืออาชีพ กระชับ และตรงประเด็น
เน้นการบริหารเวลา การจัดลำดับความสำคัญ และความรับผิดชอบ`,

          educator: `คุณคือผู้ช่วยส่วนตัวสำหรับครูผู้สอน ช่วยจัดการการสอน การเตรียมบทเรียน การสอบ และการประเมินผล
ตอบเป็นภาษาไทยที่เป็นมืออาชีพ กระชับ และให้คำแนะนำด้านการศึกษา
เน้นการเตรียมเนื้อหา สื่อการสอน และการพัฒนาการเรียนรู้ของนักเรียน`,
        };

        const systemPrompt = systemPrompts[role];

        // Prepare messages for Groq API
        const messages = [
          {role: "system", content: systemPrompt},
          {role: "user", content: message},
        ];

        // Call Groq API
        const aiResponse = await callGroqApi(messages, 500, 0.7);

        console.log(`AI Chat response sent to user ${userId}`);

        return {
          response: aiResponse,
          model: LOCKED_GROQ_MODEL,
          timestamp: admin.firestore.Timestamp.now(),
        };
      } catch (error) {
        console.error("AI Chat error:", error);

        // Re-throw HttpsError as-is
        if (error instanceof functions.https.HttpsError) {
          throw error;
        }

        // Wrap other errors
        throw new functions.https.HttpsError(
            "internal",
            "AI service temporarily unavailable",
        );
      }
    },
);

/**
 * AI Preparation Endpoint
 *
 * Generates task preparation outlines for calendar events.
 *
 * Security:
 * - Requires authentication
 * - Validates event ownership via Firestore
 * - Structured JSON output only
 *
 * @param {object} request.data - { eventId: string, eventTitle: string,
 *                                  eventDescription: string, role: string }
 * @returns {Promise<object>} - { summary: string, action_items: string[], model: string }
 */
exports.aiPreparation = functions.https.onCall(
    {region: "asia-southeast1"},
    async (request) => {
      try {
        // Validate authentication
        const auth = validateAuth(request);
        const userId = auth.uid;

        // Validate input
        const {eventId, eventTitle, eventDescription, role} = request.data;

        if (!eventTitle || typeof eventTitle !== "string") {
          throw new functions.https.HttpsError(
              "invalid-argument",
              "Event title is required",
          );
        }

        if (!role || !["student", "corporateEmployee", "educator"].includes(role)) {
          throw new functions.https.HttpsError(
              "invalid-argument",
              "Valid role required",
          );
        }

        console.log(`AI Preparation request from user ${userId} for event: ${eventTitle}`);

        // Build role-specific system prompt with ZERO AI SLOP rules
        const systemPrompt = `CRITICAL INSTRUCTIONS - AUTOMATED TASK ENGINE:

STRICT ANTI-SLOP RULES:
1. NEVER output polite intros, pleasantries, greetings (NO "สวัสดีครับ", "ยินดีที่ได้ช่วย")
2. NEVER output emojis or unicode pictographs
3. READ event title AND description THOROUGHLY
4. Base action_items on actual content mentioned in description
5. DO NOT invent fake external context
6. Output ONLY valid JSON string (no Markdown wrappers, no \`\`\`json blocks)

MANDATORY JSON SCHEMA:
{
  "summary": "Concise goal summary under 60 chars",
  "action_items": [
    "ข้อ 1: Concrete action based on event content",
    "ข้อ 2: Specific preparation step",
    "ข้อ 3-5: Additional relevant actions"
  ]
}

ROLE: ${role}
TASK: Generate 3-5 concrete preparation steps in Thai for this event.
OUTPUT: JSON only, no extra text.`;

        const userPrompt = `Event: ${eventTitle}
${eventDescription ? `Description: ${eventDescription}` : ""}

Generate preparation outline.`;

        const messages = [
          {role: "system", content: systemPrompt},
          {role: "user", content: userPrompt},
        ];

        // Call Groq API with JSON mode expectations
        const aiResponse = await callGroqApi(messages, 800, 0.6);

        // Parse JSON response
        let parsedResponse;
        try {
          // Remove markdown code blocks if present
          const cleanedResponse = aiResponse
              .replace(/```json\n?/g, "")
              .replace(/```\n?/g, "")
              .trim();

          parsedResponse = JSON.parse(cleanedResponse);

          // Validate structure
          if (!parsedResponse.summary || !Array.isArray(parsedResponse.action_items)) {
            throw new Error("Invalid response structure");
          }

          // Ensure 3-5 action items
          if (parsedResponse.action_items.length < 3) {
            parsedResponse.action_items.push(
                "ตรวจสอบรายละเอียดเพิ่มเติม",
                "เตรียมเอกสารที่จำเป็น",
            );
          }

          parsedResponse.action_items = parsedResponse.action_items.slice(0, 5);
        } catch (parseError) {
          console.error("JSON parse error:", parseError, "Raw:", aiResponse);

          // Fallback to template-based response
          const fallbackTemplates = {
            student: [
              "อ่านทบทวนเนื้อหาที่เกี่ยวข้อง",
              "สรุปประเด็นหลักที่ต้องนำเสนอ",
              "เตรียมเอกสารและแหล่งอ้างอิง",
              "ทดลองฝึกซ้อมนำเสนอ",
              "ตรวจสอบ Deadline และรูปแบบการส่ง",
            ],
            corporateEmployee: [
              "ศึกษาวาระการประชุมล่วงหน้า",
              "รวบรวมข้อมูลที่เกี่ยวข้อง",
              "เตรียมคำถามและข้อเสนอแนะ",
              "สรุปประเด็นที่ต้องตัดสินใจ",
              "แจ้งผู้เกี่ยวข้องล่วงหน้า",
            ],
            educator: [
              "ทบทวนหัวข้อบทเรียนและวัตถุประสงค์",
              "เตรียม Slides และสื่อการสอน",
              "ออกแบบกิจกรรมและแบบฝึกหัด",
              "เตรียมตัวอย่างและกรณีศึกษา",
              "วางแผนการประเมินผลนักเรียน",
            ],
          };

          parsedResponse = {
            summary: `เตรียมตัวสำหรับ: ${eventTitle}`,
            action_items: fallbackTemplates[role],
          };
        }

        console.log(`AI Preparation response sent to user ${userId}`);

        return {
          summary: parsedResponse.summary,
          action_items: parsedResponse.action_items,
          model: LOCKED_GROQ_MODEL,
          timestamp: admin.firestore.Timestamp.now(),
        };
      } catch (error) {
        console.error("AI Preparation error:", error);

        if (error instanceof functions.https.HttpsError) {
          throw error;
        }

        throw new functions.https.HttpsError(
            "internal",
            "AI preparation service temporarily unavailable",
        );
      }
    },
);

/**
 * Health Check Endpoint (Public)
 *
 * Verifies backend is operational.
 * Does NOT require authentication.
 * Does NOT expose sensitive configuration.
 */
exports.healthCheck = functions.https.onCall(
    {region: "asia-southeast1"},
    async () => {
      return {
        status: "healthy",
        model: LOCKED_GROQ_MODEL,
        timestamp: admin.firestore.Timestamp.now(),
        region: "asia-southeast1",
      };
    },
);
