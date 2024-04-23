import request from "supertest";
import { setupServer } from "../../server.js";

describe("User Integration Tests for API", () => {
  let app;
  let server;

  beforeAll(async () => {
    app = await setupServer();
    server = app.listen(8080);
  });

  it("Create a new user", async () => {
    const response = await request(app).post("/v2/user").send({
      email: "vaishnavi@example.com",
      password: "Vaish@12",
      firstName: "Vaishnavi",
      lastName: "Choukwale",
    });

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty("id");
    expect(response.body.username).toBe("vaishnavi@example.com");
  });

  it("should update an existing user", async () => {
    const response = await request(app)
      .put("/v2/user/self")
      .auth("vaishnavi@example.com", "Vaish@12")
      .send({
        firstName: "Vaish",
        lastName: "Chouk",
      });

    expect(response.status).toBe(204);
  });

  it("should get user details", async () => {
    const response = await request(app)
      .get("/v2/user/self")
      .auth("vaishnavi@example.com", "Vaish@12");

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("id");
    expect(response.body.firstName).toBe("Vaish");
    expect(response.body.lastName).toBe("Chouk");
  });

  afterAll((done) => {
    server.close(done);
  });
});
