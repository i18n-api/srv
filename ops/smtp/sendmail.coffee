#!/usr/bin/env coffee

> nodemailer

{user,port,to,pass,smtp,subject} = process.env

if not smtp
  smtp = 'smtp.'+user.split('@').pop()

port = (port-0) or 465

console.log 'smtp',smtp+':'+port

transporter = nodemailer.createTransport({
    host: smtp
    debug: true
    logger: true
    #secure: true
    port
    auth: {
      user
      pass
    }
    tls:{
      rejectUnauthorized: false
    }
})

subject = subject or " 🚀 test mail from #{user} #{new Date().toISOString().slice(0,19).replace('T',' ')} "

mail = {
    from: "WAC.Tax<#{user}>"
    to
    subject
    text: subject
    html: "<h1>#{subject}</h1>"
}

console.log await transporter.sendMail(mail)
console.log subject
