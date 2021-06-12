import fetch from "node-fetch";

const ip = "192.168.0.135";
const username = "admin";
const password = "password";

(async () => {
	// request a login token
	const request = await fetch(`http://${ip}/cgi-bin/api.cgi?cmd=Login&token=null`, {
		credentials: "omit",
		headers: {
			"User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:87.0) Gecko/20100101 Firefox/87.0",
			Accept: "*/*",
			"Accept-Language": "en-US,en;q=0.5",
			"Content-Type": "application/json",
			"X-Requested-With": "XMLHttpRequest",
			"Sec-GPC": "1",
			Pragma: "no-cache",
			"Cache-Control": "no-cache",
		},
		referrer: `http://${ip}/`,
		body: `[{"cmd":"Login","action":0,"param":{"User":{"userName":"${username}","password":"${password}"}}}]`,
		method: "POST",
		mode: "cors",
	});

	const response = await request.json();
	const authToken = response[0].value.Token.name;

	// Then to reboot the camera using the login token
	await fetch(`http://${ip}/cgi-bin/api.cgi?cmd=Reboot&token=${authToken}`, {
		credentials: "omit",
		headers: {
			"User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:87.0) Gecko/20100101 Firefox/87.0",
			Accept: "*/*",
			"Accept-Language": "en-US,en;q=0.5",
			"Content-Type": "application/json",
			"X-Requested-With": "XMLHttpRequest",
			"Sec-GPC": "1",
			Pragma: "no-cache",
			"Cache-Control": "no-cache",
		},
		referrer: `http://${ip}/?${authToken}`,
		body: '[{"cmd":"Reboot","action":0,"param":{}}]',
		method: "POST",
		mode: "cors",
	});
})().catch((e) => {
	console.error("failed somehow");
	console.error(e);
});
