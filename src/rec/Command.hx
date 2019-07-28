package rec;

import kha.FastFloat;

enum abstract Command(Int) to FastFloat {
	var FrameBegin;
	var Begin;
	var SetColor;
	var Transformation;
	var DrawImage;
	var DrawScaledSubImage;
	var End;
	var FrameEnd;
}
