import express from 'express';
import healthCheckController from '../controllers/healthCheckController.js';

const router = express.Router();

// Disable body-parser for empty string
router.use(express.text({ type: '*/*' }));

// Only GET method os aloowed
router.get('/', healthCheckController.checkHealth);

// For all methods other than GET, return 'Status: 405 Method Not Allowed'
router.all('/', (req, res) => {
    res.set('Pragma', 'no-cache');
    res.set('X-Content-Type-Options', 'nosniff')
    res.set('Cache-Control', 'no-cache, no-store, must-revalidate');
    res.status(405).send();
});

export default router;
