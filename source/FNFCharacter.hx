package;

import openfl.display.Sprite;
import openfl.Lib;
import swf.exporters.animate.AnimateLibrary;
import swf.exporters.animate.AnimateSymbol;

class FNFCharacter extends Sprite {
    public var symbol:AnimateSymbol;

    public function new(library:AnimateLibrary, name:String) {
        super();
        symbol = library.createSymbol(name);
        addChild(symbol);
    }

    public function playAnim(anim:String) {
        symbol.gotoAndPlay(anim);
    }

    public function update() {
        // Called every frame
        symbol.advanceFrame();
    }
}
