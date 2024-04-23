import bcrypt from 'bcrypt';
import User from '../models/userModel.js';

const basicAuth = async (req, res, next) => {
    const authHeader = req.headers['authorization'];

    if (!authHeader || !authHeader.startsWith('Basic ')) {
        return res.status(401).json({ error: 'Authentication header missing or invalid.' });
    }

    // Extract credentials from the authorization header
    const base64Credentials = authHeader.split(' ')[1];
    const credentials = Buffer.from(base64Credentials, 'base64').toString('utf-8');
    const [username, password] = credentials.split(':');

    try {
        const user = await User.findOne({ where: { username } });
        if (!user) {
            console.error('User not found:', username);
            return res.status(401).json({ error: 'Invalid username or password.' });
        }

        console.log('Found user:', user.username);
        
        // Compare the provided password with the hashed password stored in the database
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            console.error('Invalid password:', username);
            return res.status(401).json({ error: 'Invalid username or password.' });
        }

        console.log('Password is valid for user:', user.username);

        // If authentication succeeds, set req.user to the authenticated user and proceed with the request
        req.user = user;
        next();
    } catch (error) {
        console.error('Error authenticating user:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
};
    
export default basicAuth;