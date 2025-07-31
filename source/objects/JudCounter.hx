package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText.FlxTextBorderStyle;
import backend.ClientPrefs;
import backend.Rating;
import backend.Paths;
import backend.Language;

class JudCounter extends FlxTypedGroup<FlxText>
{
    // Textos individuales para cada judgment
    var epicsText:FlxText;
    var sicksText:FlxText;
    var goodsText:FlxText;
    var badsText:FlxText;
    var shitsText:FlxText;
    var missesText:FlxText;
    var comboText:FlxText;
    var maxComboText:FlxText;

    // Colores para cada judgment
    static final EPICS_COLOR:FlxColor = 0xFFA17FFF;  // Púrpura
    static final SICKS_COLOR:FlxColor = 0xFF7FC9FF;  // Cyan
    static final GOODS_COLOR:FlxColor = 0xFF7FFF8E;  // Verde
    static final BADS_COLOR:FlxColor = 0xFF888888;   // Gris
    static final SHITS_COLOR:FlxColor = 0xFFFF7F7F;  // Rojo claro
    static final MISSES_COLOR:FlxColor = FlxColor.RED; // Rojo
    static final COMBO_COLOR:FlxColor = FlxColor.WHITE; // Sin color - blanco
    static final MAX_COMBO_COLOR:FlxColor = FlxColor.WHITE; // Sin color - blanco

    // Variables para el efecto bump
    var bumpTweens:Map<FlxText, FlxTween> = new Map<FlxText, FlxTween>();

    // Configuración
    public var baseX:Float = 10;
    public var baseY:Float = 0;
    public var fontSize:Int = 20;
    public var spacing:Float = 22; // Más juntos

    public function new(x:Float = 10, y:Float = 0)
    {
        super();
        
        baseX = x;
        baseY = y;
        
        // Calcular Y centrado verticalmente
        if (baseY == 0)
            baseY = (FlxG.height / 2) - 100;

        createTexts();
        updateVisibility();
    }

    function createTexts()
    {
        // Crear cada texto con su color específico y traducción
        epicsText = createJudgmentText(Language.getPhrase('judgement_epics', 'Epics') + ':  0', EPICS_COLOR, 0);
        sicksText = createJudgmentText(Language.getPhrase('judgement_sicks', 'Sicks') + ':  0', SICKS_COLOR, 1);
        goodsText = createJudgmentText(Language.getPhrase('judgement_goods', 'Goods') + ':  0', GOODS_COLOR, 2);
        badsText = createJudgmentText(Language.getPhrase('judgement_bads', 'Bads') + ':   0', BADS_COLOR, 3);
        shitsText = createJudgmentText(Language.getPhrase('judgement_shits', 'Shits') + ':  0', SHITS_COLOR, 4);
        missesText = createJudgmentText(Language.getPhrase('judgement_misses', 'Misses') + ': 0', MISSES_COLOR, 5);
        comboText = createJudgmentText(Language.getPhrase('judgement_combo', 'Combo') + ':    0', COMBO_COLOR, 6);
        maxComboText = createJudgmentText(Language.getPhrase('judgement_max_combo', 'M. Combo') + ': 0', MAX_COMBO_COLOR, 7);

        // Agregar al grupo
        add(epicsText);
        add(sicksText);
        add(goodsText);
        add(badsText);
        add(shitsText);
        add(missesText);
        add(comboText);
        add(maxComboText);
    }

    function createJudgmentText(text:String, color:FlxColor, index:Int):FlxText
    {
        var judText = new FlxText(baseX, baseY + (spacing * index), 0, text, fontSize);
        judText.setFormat(Paths.defaultFont(), fontSize, color, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        judText.scrollFactor.set();
        judText.alpha = 1;
        judText.borderSize = 2;
        return judText;
    }

    public function updateCounter(ratingsData:Array<Rating>, songMisses:Int, combo:Int, maxCombo:Int)
    {
        if (!ClientPrefs.data.judgementCounter) {
            updateVisibility();
            return;
        }

        // Actualizar textos con traducción
        epicsText.text = Language.getPhrase('judgement_epics', 'Epics') + ': ${ratingsData[0].hits}';
        sicksText.text = Language.getPhrase('judgement_sicks', 'Sicks') + ': ${ratingsData[1].hits}';
        goodsText.text = Language.getPhrase('judgement_goods', 'Goods') + ': ${ratingsData[2].hits}';
        badsText.text = Language.getPhrase('judgement_bads', 'Bads') + ': ${ratingsData[3].hits}';
        shitsText.text = Language.getPhrase('judgement_shits', 'Shits') + ': ${ratingsData[4].hits}';
        missesText.text = Language.getPhrase('judgement_misses', 'Misses') + ': $songMisses';
        comboText.text = Language.getPhrase('judgement_combo', 'Combo') + ': $combo';
        maxComboText.text = Language.getPhrase('judgement_max_combo', 'M. Combo') + ': $maxCombo';

        updateVisibility();
    }

    public function updateVisibility()
    {
        var shouldShow = ClientPrefs.data.judgementCounter;
        forEach(function(text:FlxText) {
            text.visible = shouldShow;
        });
    }

    // Efecto bump cuando se acierta una nota
    public function doBump(judgmentIndex:Int)
    {
        if (!ClientPrefs.data.judgementCounter) return;

        var targetText:FlxText = null;
        
        switch(judgmentIndex) {
            case 0: targetText = epicsText;
            case 1: targetText = sicksText;
            case 2: targetText = goodsText;
            case 3: targetText = badsText;
            case 4: targetText = shitsText;
            default: return; // Índice inválido
        }

        if (targetText == null) return;

        // Cancelar tween anterior si existe
        if (bumpTweens.exists(targetText) && bumpTweens.get(targetText) != null) {
            bumpTweens.get(targetText).cancel();
        }

        // Efecto bump
        targetText.scale.set(1.5, 1.5);
        var bumpTween = FlxTween.tween(targetText.scale, {x: 1, y: 1}, 0.15, {
            ease: FlxEase.expoOut,
            onComplete: function(twn:FlxTween) {
                bumpTweens.remove(targetText);
            }
        });
        
        bumpTweens.set(targetText, bumpTween);
    }

    // Efecto bump para combo
    public function doComboBump()
    {
        if (!ClientPrefs.data.judgementCounter) return;

        // Bump para combo actual - más sutil
        if (bumpTweens.exists(comboText) && bumpTweens.get(comboText) != null) {
            bumpTweens.get(comboText).cancel();
        }

        comboText.scale.set(1.5, 1.5);
        var comboTween = FlxTween.tween(comboText.scale, {x: 1, y: 1}, 0.3, {
            ease: FlxEase.expoOut,
            onComplete: function(twn:FlxTween) {
                bumpTweens.remove(comboText);
            }
        });
        bumpTweens.set(comboText, comboTween);
    }

    // Efecto bump para max combo
    public function doMaxComboBump()
    {
        if (!ClientPrefs.data.judgementCounter) return;

        if (bumpTweens.exists(maxComboText) && bumpTweens.get(maxComboText) != null) {
            bumpTweens.get(maxComboText).cancel();
        }

        maxComboText.scale.set(1.5, 1.5);
        var maxTween = FlxTween.tween(maxComboText.scale, {x: 1, y: 1}, 0.3, {
            ease: FlxEase.expoOut,
            onComplete: function(twn:FlxTween) {
                bumpTweens.remove(maxComboText);
            }
        });
        bumpTweens.set(maxComboText, maxTween);
    }

    // Efecto bump para misses
    public function doMissBump()
    {
        if (!ClientPrefs.data.judgementCounter) return;

        if (bumpTweens.exists(missesText) && bumpTweens.get(missesText) != null) {
            bumpTweens.get(missesText).cancel();
        }

        missesText.scale.set(1.5, 1.5);
        var missTween = FlxTween.tween(missesText.scale, {x: 1, y: 1}, 0.3, {
            ease: FlxEase.elasticOut,
            onComplete: function(twn:FlxTween) {
                bumpTweens.remove(missesText);
            }
        });
        bumpTweens.set(missesText, missTween);
    }

    // Configurar cámaras
    public function setCameras(cameras:Array<flixel.FlxCamera>)
    {
        forEach(function(text:FlxText) {
            text.cameras = cameras;
        });
    }

    // Reposicionar el contador
    public function setPosition(x:Float, y:Float)
    {
        baseX = x;
        baseY = y;
        
        var index = 0;
        forEach(function(text:FlxText) {
            text.setPosition(baseX, baseY + (spacing * index));
            index++;
        });
    }

    override function destroy()
    {
        // Limpiar tweens
        for (tween in bumpTweens) {
            if (tween != null) tween.cancel();
        }
        bumpTweens.clear();
        
        super.destroy();
    }
}