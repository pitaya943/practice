const functions = require("firebase-functions");

const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const cors = require("cors")({origin: true});
admin.initializeApp();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "example@gmail.com",
    pass: "password",
  },
});

exports.sendMail = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    // getting dest email by query string
    const dest = req.query.dest;

    const mailOptions = {
      from: "Kuei <example@gmail.com>",
      to: dest,
      subject: "宇丞-每月簽到資訊", // email subject
      html: `<p style="font-size: 16px;">Pickle Riiiiiiiiiiiiiiiick!!</p>
                <br />
                <img src="https://cdn.europosters.eu/image/750/posters/rick-and-morty-pickle-rick-i51002.jpg" />
            `, // email content in HTML
    };

    // returning result
    return transporter.sendMail(mailOptions, (erro, info) => {
      if (erro) {
        return res.send(erro.toString());
      }
      return res.send("Sended");
    });
  });
});
