package ld26;

import nme.Lib;
import ru.stablex.Assets;
import ru.stablex.ui.UIBuilder;


/**
* Main class
*
*/
class Main{

    //game config
    static public var cfg : TCfg;
    //levels config
    static public var levels : Array<TLevelCfg>;
    //predefined structures for features
    static public var structs : Array<Array<Array<Int>>>;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/

    /**
    * Entry point
    *
    */
    static public function main () : Void {
        Main.cfg     = Assets.embed("assets/cfg.hx");
        Main.levels  = Assets.embed("assets/levels.hx");
        Main.structs = Assets.embed("assets/features.hx");

        UIBuilder.regClass("ld26.Main");
        UIBuilder.regClass("ld26.Project");
        UIBuilder.regClass("ld26.Level");
        UIBuilder.regClass("ld26.Block");
        UIBuilder.init();

        var level : Level = UIBuilder.buildFn("ui/level.xml")();
        Lib.current.addChild(level);
trace(Main.levels[0]);
        level.load(Main.levels[0]);
        level.start();
    }//function main()

/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Constructor
    *
    */
    public function new () : Void {
    }//function new()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Main