const { chromium } = require('playwright');
const { spawn } = require('node:child_process');
const fs = require('node:fs');
const assert = require('node:assert/strict');
(async () => {
  fs.mkdirSync('qa', { recursive: true });
  const server = spawn('python3', ['-m', 'http.server', '8765', '--directory', 'build/web']);
  let browser;
  let page;
  const errors = [];
  try {
    browser = await chromium.launch({ args: ['--enable-unsafe-swiftshader', '--use-angle=swiftshader', '--no-sandbox'] });
    page = await browser.newPage({ viewport: { width: 1280, height: 720 }, hasTouch: true });
    page.on('pageerror', error => errors.push(error.message));
    page.on('console', msg => { console.log('BROWSER:',msg.type(),msg.text()); if (/SCRIPT ERROR|Parse Error|ERROR:/.test(msg.text())) errors.push(msg.text()); });
    await page.goto('http://127.0.0.1:8765/?qa=1');
    await page.waitForTimeout(3000);
    await page.screenshot({path:'qa/startup.png'});
    console.log('STARTUP DOM:',await page.locator('body').innerText());
    await page.waitForFunction(() => !!document.querySelector('canvas')?.dataset.aervalon, null, { timeout: 60000 });
    const readState = () => page.locator('canvas').evaluate(el => JSON.parse(el.dataset.aervalon));
    await page.waitForTimeout(1500);
    await page.screenshot({ path: 'qa/eryndor-village.png' });
    await page.keyboard.press('e');
    await page.waitForTimeout(300);
    await page.screenshot({ path: 'qa/eryndor-mara.png' });
    assert.equal((await readState()).quest_started, true, 'Keyboard dialogue starts Mara quest');
    await page.keyboard.press('i');
    await page.waitForTimeout(200);
    assert.equal((await readState()).modal,true,'Inventory opens');
    await page.screenshot({path:'qa/inventory-desktop.png'});
    await page.keyboard.press('Escape');
    await page.keyboard.press('Space');
    await page.waitForTimeout(150);
    await page.screenshot({ path: 'qa/eryndor-attack.png' });
    // Walk to the actual merchant, interact, then buy through rendered buttons.
    async function walkAxis(axis,target,keyPositive,keyNegative) {
      const state=await readState();
      const offset=target-state.position[axis];
      const key=offset>0?keyPositive:keyNegative;
      await page.keyboard.down(key);
      await page.waitForTimeout(Math.abs(offset)/170*1000);
      await page.keyboard.up(key);
      await page.waitForTimeout(150);
    }
    await walkAxis(0,500,'d','a');
    await walkAxis(1,650,'s','w');
    await page.keyboard.press('e');
    await page.waitForTimeout(250);
    assert.equal((await readState()).shop,'merchant','Nearby merchant opens actual shop');
    async function pressUI(prefix) {
      const state=await readState();
      const entry=Object.entries(state.buttons).find(([text])=>text.startsWith(prefix));
      assert.ok(entry,'Visible UI button: '+prefix);
      const bounds=await page.locator('canvas').boundingBox();
      await page.mouse.click(bounds.x+entry[1][0]/state.viewport[0]*bounds.width,bounds.y+entry[1][1]/state.viewport[1]*bounds.height);
      await page.waitForTimeout(200);
    }
    await pressUI('Poção');
    await pressUI('Comprar •');
    assert.equal((await readState()).coins,4,'Shop UI deducts potion price');
    assert.equal((await readState()).inventory.potion,3,'Shop UI adds bought potion');
    await page.screenshot({path:'qa/shop-merchant.png'});
    await page.keyboard.press('Escape');
    await walkAxis(1,470,'s','w');
    await walkAxis(0,670,'d','a');
    await page.keyboard.press('e');
    await page.waitForTimeout(250);
    assert.equal((await readState()).shop,'borin','Borin is reachable from the forge frontage');
    await page.screenshot({path:'qa/shop-borin.png'});
    await page.keyboard.press('Escape');
    // Return to open village ground for the mobile joystick test.
    await walkAxis(1,600,'s','w');
    await page.setViewportSize({ width: 844, height: 390 });
    await page.waitForTimeout(400);
    await page.screenshot({ path: 'qa/eryndor-mobile.png' });
    await page.keyboard.press('i');
    await page.waitForTimeout(250);
    await page.screenshot({path:'qa/inventory-mobile.png'});
    assert.equal((await readState()).modal,true,'Inventory opens in mobile viewport');
    await page.keyboard.press('Escape');
    const cdp = await page.context().newCDPSession(page);
    const before = await readState();
    const bounds = await page.locator('canvas').boundingBox();
    const cssPoint = p => ({x:bounds.x+p[0]/before.viewport[0]*bounds.width,y:bounds.y+p[1]/before.viewport[1]*bounds.height});
    const joy = cssPoint(before.joystick);
    const stick = cssPoint([before.joystick[0]+52,before.joystick[1]]);
    const attack = cssPoint(before.attack);
    await cdp.send('Input.dispatchTouchEvent', {type:'touchStart',touchPoints:[{...joy,id:0}]});
    await cdp.send('Input.dispatchTouchEvent', {type:'touchMove',touchPoints:[{...stick,id:0}]});
    await page.waitForTimeout(800);
    assert.ok((await readState()).position[0] > before.position[0]+20, 'Touch joystick moves hero');
    await cdp.send('Input.dispatchTouchEvent', {type:'touchStart',touchPoints:[{...stick,id:0},{...attack,id:1}]});
    await page.waitForTimeout(150);
    await cdp.send('Input.dispatchTouchEvent', {type:'touchEnd',touchPoints:[]});
    await page.screenshot({ path: 'qa/eryndor-mobile-move.png' });
    await page.setViewportSize({ width: 390, height: 844 });
    await page.waitForTimeout(300);
    await page.screenshot({ path: 'qa/eryndor-portrait.png' });
    assert.equal((await readState()).portrait,true,'Portrait rotation notice is visible');
    await page.reload();
    await page.waitForFunction(() => !!document.querySelector('canvas')?.dataset.aervalon, null, { timeout: 60000 });
    assert.equal((await readState()).quest_started,true,'Web refresh keeps quest progress');
    assert.equal((await readState()).equipment.weapon,'rusty_sword','Web refresh keeps equipment');
    assert.deepEqual(errors, [], 'No Godot or JavaScript runtime errors');
    fs.writeFileSync('qa/browser-result.json', JSON.stringify({passed:true,errors,viewports:['1280x720','844x390','390x844']},null,2));
    console.log('PASS: WebGL2 startup, keyboard interaction/attack, landscape/portrait layout, multitouch input, no runtime errors');
  } catch(error) {
    if(page) {
      await page.screenshot({path:"qa/failure.png"}).catch(()=>{});
      console.log("FAILURE DOM:",await page.locator("body").innerText().catch(()=>"unavailable"));
    }
    throw error;
  } finally {
    if (browser) await browser.close();
    server.kill();
    fs.writeFileSync('qa/console-errors.json', JSON.stringify(errors,null,2));
  }
})().catch(error => { console.error(error); process.exit(1); });
