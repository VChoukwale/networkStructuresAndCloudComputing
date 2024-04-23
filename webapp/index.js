import userRoutes from "./routes/userRoute.js";
import healthCheckRoute from "./routes/healthCheckRoute.js";
import { setupServer } from "./server.js";
import dotenv from "dotenv";

dotenv.config();
const app = await setupServer();

app.use("/healthz", healthCheckRoute);
app.use("/v2/user", userRoutes);

const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});



