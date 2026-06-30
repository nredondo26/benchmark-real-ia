const request = require('supertest');
const app = require('../src/index');

describe('GET /', () => {
  it('responds with JSON message and ok status', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('message', 'CI/CD Challenge API');
    expect(res.body).toHaveProperty('status', 'ok');
  });
});

describe('GET /health', () => {
  it('responds with healthy status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('status', 'healthy');
  });
});
