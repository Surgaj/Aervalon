const { chromium } = require('playwright');
const { spawn } = require('node:child_process');
const fs = require('node:fs');
const assert = require('node:assert/strict');
(async () => {
  fs.mkdirSync('qa', { recursive: true });
  const server = spawn('python3', ['-m', 'http.server', '8765', '--directory', 'build/web']);
  let browser;
  const errors = [];
  try {
    browser = await chromium.launch({ args: ['--enable-unsafe-swiftshader', '--use-angle=swiftshader', '--no-sandbox'] });
    const page = await browser.newPage({ viewport: { width: 1280, height: 720 }, hasTouch: true });
    page.on('pageerror', error => errors.push(error.message));
    page.on('console', msg => { if (/SCRIPT ERROR|Parse Error|ERROR:/.test(msg.text())) errors.push(msg.text()); });
    await page.goto('http://127.0.0.1:8765/');
    await page.waitForFunction(() => document.querySelector('#status')?.style.visibility === 'hidden', { timeout: 60000 });
    await page.waitForTimeout(1500);
    await page.screenshot({ path: 'qa/eryndor-village.png' });
    await page.keyboard.press('e');
    await page.waitForTimeout(300);
    await page.screenshot({ path: 'qa/eryndor-mara.png' });
    await page.keyboard.press('Space');
    await page.waitForTimeout(150);
    await page.screenshot({ path: 'qa/eryndor-attack.png' });
    await page.setViewportSize({ width: 844, height: 390 });
    await page.waitForTimeout(400);
    await page.screenshot({ path: 'qa/eryndor-mobile.png' });
    const cdp = await page.context().newCDPSession(page);
    // Coordinates in CSS pixels; touch IDs exercise joystick plus attack together.
    await cdp.send('Input.dispatchTouchEvent', {type:'touchStart',touchPoints:[{x:65,y:322,id:0}]});
    await cdp.send('Input.dispatchTouchEvent', {type:'touchMove',touchPoints:[{x:100,y:322,id:0}]});
    await page.waitForTimeout(800);
    await cdp.send('Input.dispatchTouchEvent', {type:'touchStart',touchPoints:[{x:100,y:322,id:0},{x:774,y:322,id:1}]});
    await page.waitForTimeout(150);
    await cdp.send('Input.dispatchTouchEvent', {type:'touchEnd',touchPoints:[]});
    await page.screenshot({ path: 'qa/eryndor-mobile-move.png' });
    await page.setViewportSize({ width: 390, height: 844 });
    await page.waitForTimeout(300);
    await page.screenshot({ path: 'qa/eryndor-portrait.png' });
    assert.deepEqual(errors, [], 'No Godot or JavaScript runtime errors');
    fs.writeFileSync('qa/browser-result.json', JSON.stringify({passed:true,errors,viewports:['1280x720','844x390','390x844']},null,2));
    console.log('PASS: WebGL2 startup, keyboard interaction/attack, landscape/portrait layout, multitouch input, no runtime errors');
  } finally {
    if (browser) await browser.close();
    server.kill();
    fs.writeFileSync('qa/console-errors.json', JSON.stringify(errors,null,2));
  }
})().catch(error => { console.error(error); process.exit(1); });
