import { Handler } from "aws-lambda";

export const handler: Handler = async (event) => {
  console.log("🚀 Hello from Lambda!");
  console.log("Event received:", JSON.stringify(event, null, 2));

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello World from Lambda 👋",
      input: event,
    }),
  };
};
