package ld26;

import nme.Lib;
import nme.net.SharedObject;
import ru.stablex.Assets;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.ViewStack;
import ru.stablex.ui.widgets.Widget;

#if flash
import com.newgrounds.API;
import com.newgrounds.APIEvent;
#end

#if haxe3
typedef Hash<T> = Map<String,T>;
#end

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
    //root display object of the game
    static public var root : Widget;
    //viewstack for game screens
    static public var vs : ViewStack;
    //game data (settings & progress)
    static public var data : TData;
    static private var _storage : SharedObject;

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

        Main.readData();

        UIBuilder.regClass("ld26.Main");
        UIBuilder.regClass("ld26.Project");
        UIBuilder.regClass("ld26.Level");
        UIBuilder.regClass("ld26.Block");
        UIBuilder.regClass("ld26.Score");
        UIBuilder.regClass("ld26.Popup");
        UIBuilder.regClass("ld26.Sfx");

        UIBuilder.init("ui/defaults.xml");

        Main.root = UIBuilder.buildFn("ui/main.xml")();
        Main.vs   = Main.root.getChildAs("vs", ViewStack);

        Lib.current.addChild(Main.root);

        #if flash
            API.debugMode = API.RELEASE_MODE;
            // API.addEventListener(APIEvent.API_CONNECTED, function(e:APIEvent){
            //     trace({
            //         success : e.success,
            //         error  : e.error
            //     });
            // });
            API.connect(Lib.current, "31946:ySUcVo4J", "nF4rBxYXVtomCfLnE1UEN7dtK3PGsDTX");
            API.addEventListener(APIEvent.SCORE_POSTED, function(e:APIEvent){
                if( !e.success ){
                    trace({
                        success : e.success,
                        error  : e.error
                    });
                }
            });
        #end
    }//function main()


    /**
    * Save game data & settings
    *
    */
    static public function save () : Void {
        if( Main._storage != null ){
            Main._storage.data.progress = Main.data;
            Main._storage.flush();
        }
    }//function save()


    /**
    * Read saved settings and game progress
    *
    */
    static public function readData () : Void {
        try{
        #if desktop
            Main._storage = SharedObject.getLocal('ld26_coder', '.');
        #else
            Main._storage = SharedObject.getLocal('ld26_coder');
        #end
        }catch(e:Dynamic){
            //potato???
        }

        Main.data = (
            Main._storage != null && Main._storage.data.progress != null
                ? Main._storage.data.progress
                : {
                    story : {
                        level : 0,
                        score : 0
                    },
                    endless : {
                        score : 0
                    }
                }
        );
    }//function readData()


    /**
    * Start story game
    *
    */
    static public function playStory (continueGame:Bool = false) : Void {
        #if flash
            //com.newgrounds.API.unlockMedal("Hardcore coder");
        #end
        //if saved game was found
        if( !continueGame && Main.data.story.level > 0 ){
            UIBuilder.buildFn("ui/popup/restartStory.xml")().show();
        }else{
            Main.data.story.level = 0;
            Main.data.story.score = 0;
            Main.save();
            Main.playLevel(Main.data.story.level);
        }
    }//function playStory()


    /**
    * Start specified level
    *
    */
    static public function playLevel (n:Int) : Void {
        //no more levels
        if( Main.levels.length <= n ) return;

        //if level instance already exists, destroy it after creating new instance
        var old : Level = UIBuilder.getAs("level", Level);
        //free widget id to use it in new instance
        if( old != null ){
            old.id   = old.id + Math.random();
            old.name = old.name + Math.random();
        }

        Main.data.story.level = n;
        Main.save();

        //create new instance
        var level : Level = UIBuilder.buildFn("ui/level.xml")();
        level.load(Main.levels[n], n);
        Main.vs.addChild(level);

        //show level and start playing
        Main.vs.show("level", function(){
            if( old != null ) old.free();
            level.start();
        });
    }//function playLevel()


    /**
    * Start endless game
    *
    */
    static public function playEndless () : Void {
        //if level instance already exists, destroy it after creating new instance
        var old : Level = UIBuilder.getAs("level", Level);
        //free widget id to use it in new instance
        if( old != null ){
            old.id   = old.id + Math.random();
            old.name = old.name + Math.random();
        }

        //create new instance
        var level : Level = UIBuilder.buildFn("ui/level.xml")();
        level.load(Main.levels[0], -1);
        Main.vs.addChild(level);

        //show level and start playing
        Main.vs.show("level", function(){
            if( old != null ) old.free();
            level.start();
        });
    }//function playEndless()


    /**
    * Request LD badge for story mode completion
    *
    */
    static public function requestBadge (name:String, score:Int) : Void {
        #if flash
            var request     = new nme.net.URLRequest("http://stablex.ru/ld26/badge/");
            var variables   = new nme.net.URLVariables();
            variables.name  = name;
            variables.score = score;
            request.method  = nme.net.URLRequestMethod.POST;
            request.data    = variables;
            new nme.net.URLLoader(request);
        #end
    }//function requestBadge()


    /**
    * Handle story mode completion
    *
    */
    static public function storyCompleted () : Void {
    }//function storyCompleted()


    /**
    * Post score to newgrounds
    *
    */
    static public function postScore (board:String, score:Int) : Void {
        #if flash
            try{
                API.postScore(board, score);
            }catch(e:Dynamic){
                trace(e);
            }
        #end
    }//function postScore()


    /**
    * Unlock medal on newgrounds
    *
    */
    static public function unlockMedal (medal:String) : Void {
        #if flash
            try{
                API.unlockMedal(medal);
            }catch(e:Dynamic){
                trace(e);
            }
        #end
    }//function unlockMedal()


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