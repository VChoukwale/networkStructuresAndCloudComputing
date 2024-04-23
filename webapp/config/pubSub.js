import { PubSub } from "@google-cloud/pubsub";

export const cloudFunction = async (
  message,
  projectId,
  topicNameOrId,
  subscriptionName
) => {
  // Instantiates a client
  const pubsub = new PubSub({ projectId });

  // References an existing topic
  const topic = pubsub.topic(topicNameOrId);

  // References an existing subscription
  const subscription = pubsub.subscription(subscriptionName)

  // Define message handler
  const handleMessage = (message) => {
    console.log("Received Message is :", message.data.toString());
    //process.exit(0);
  };

  // Define error handler
  const handleError = (error) => {
    console.error("Received Error :", error);
    //process.exit(1);
  };

  // Receive callbacks for new messages on the subscription
  subscription.on("message", handleMessage);

  // Receive callbacks for errors on the subscription
  subscription.on("error", handleError);

  try {
    // Publish the message to the topic
    await topic.publishMessage({ data: Buffer.from(message) });
    console.log("Message published to topic :", topicNameOrId);
    return "Message published successfully";
  } catch (error) {
    console.error("Error Generated:", error);
    throw error;
  } finally {
    // Clean up event listeners
    subscription.removeListener("message", handleMessage);
    subscription.removeListener("error", handleError);
  }
};