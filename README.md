## KhaRec

Simple way to write graphics2 commands to file and play it.
Only for fun, html5 and g2 on g4.

### Implementation details

`Graphics2` is shadowed with almost same code, but has `Recorder.drawImage(img, x, y)` call in `drawImage` function, same for other commands from `rec.Command` (no font/drawString currently). `Recorder` does nothing if not activated in user code. After activation it start writing some commands into `FastFloat` array and then saves it to a file with compression. `Player` just reads that array and run a record in the loop.

### Usage

First of all, add [pako.min.js](https://raw.githubusercontent.com/hamaluik/haxe-pako/master/libs/pako.min.js) to `Assets` and to [index.html](https://github.com/Kode/Kha/wiki/HTML5#custom-indexhtml-and-js-libraries). 30s 60fps record with pako compression will have 2 MB size for 1k draws in a frame. Don't ask how fat it can be without compression.

Lets add code in game for Recorder/Player activation in `onKeyDown` event:
```haxe
if (key == Zero) {
	// Start/Stop recording on `0` key
	if (!rec.Recorder.isActive) rec.Recorder.enable();
	else rec.Recorder.save();
	return;
}
if (key == Nine) {
	// Start/Stop playing from file on `9` key
	// Recorder writes all renderTargets as one image,
	// so it supports only one renderTarget
	// We can send it to Player
	if (!rec.Player.isActive) rec.Player.enable(optionalAtlasImage);
	else rec.Player.disable();
	return;
}
```
Code for `Player` in render loop:
```haxe
if (rec.Player.isActive) {
	rec.Player.render(framebuffer.g2);
	return;
}
```
And code for `Recorder` in render loop:
```haxe
final g = framebuffer.g2;
rec.Recorder.frameBegin(g);
// actual render code
// g.begin();
// ...
// g.end();
rec.Recorder.frameEnd();
```
That's all folks! Beware, `Recorder` writes image ids to data array, so any new image in `Assets` will break recordings. Can be avoided with `ImageName => IntId` map in data file, but this is just concept, feel free to hack or contribute.
