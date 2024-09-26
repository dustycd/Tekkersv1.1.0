// server.js
const express = require('express');
const nodemailer = require('nodemailer');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Configure your email service
const transporter = nodemailer.createTransport({
  service: 'gmail', // Use your email service provider
  auth: {
    user: 'tekkers.v2@gmail.com',
    pass: 'Jojnyj-sehgeW-wakte3',
  },
});

app.post('/send-verification-email', (req, res) => {
  const { email, code } = req.body;

  const mailOptions = {
    from: 'tekkers.v2@gmail.com', // Your email
    to: email,
    subject: 'Your Verification Code',
    text: `Your verification code is: ${code}`,
  };

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.error(error);
      res.status(500).send({ message: 'Failed to send email' });
    } else {
      console.log('Email sent: ' + info.response);
      res.status(200).send({ message: 'Email sent' });
    }
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
});