package rec;

import kha.FastFloat;

enum abstract Command(Int) to FastFloat {
	var FrameBegin;
	var Begin;
	var SetColor;
	var Transformation;
	var DrawImage;
	var DrawScaledSubImage;
	var DrawRect;
	var FillRect;
	var DrawLine;
	var FillTriangle;
	var End;
	var FrameEnd;
}
