const samanage = require('./lib/samanage.js')
const email = 'chris.walls+apitest@samanage.com'
const pass = 'Test1234'
const invalidEmail = 'chris.walls+apitest@samanage.comzzz'
const invalidPass = 'jsdahifosdgfasoudygf'
let controller = new samanage(email,pass)
let controller2 = new samanage(invalidEmail,invalidPass)



console.log(`Controller: ${controller}`)
console.log(`Controller2: ${controller2}`)
// console.log(`Authorization: ${controller.authorize()}`)
// console.log(`samanage.default: ${samanage.default(email,pass)}`)