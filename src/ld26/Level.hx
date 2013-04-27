package ld26;

import haxe.Timer;
import motion.Actuate;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Progress;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;



/**
* Level instance
*
*/
class Level extends Widget{
    //Duration of one step of moving feature
    static public var speed : Float = 1;

    //game field
    public var field : Widget;
    //features to implement
    public var features : Array<Feature>;
    //current feature
    public var current : Feature;
    //next feature
    public var next : Feature;
    //widget where to show next feature
    public var displayNext : Widget;
    //player's project
    public var project : Project;
    //deadline bar
    public var deadline : Progress;
    //indicator for amount of features left to implement
    public var featuresLeft (default,set_featuresLeft) : Int = 0;
    public var featuresLeftLabel : Text;
    //level config
    public var cfg : TLevelCfg;
    //level number
    public var num : Int = -1;
    //level stopped (voctory/gameover)
    public var stopped : Bool = false;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/



/*******************************************************************************
*       INSTANCE METHODS
*******************************************************************************/

    /**
    * Get level components on creation complete
    *
    */
    override public function onCreate () : Void {
        super.onCreate();

        this.field             = this.getChild("field");
        this.project           = this.field.getChildAs("project", Project);
        this.displayNext       = this.getChild("displayNext");
        this.deadline          = this.getChildAs("deadline", Progress);
        this.featuresLeftLabel = this.getChildAs("featuresLeft", Text);
    }//function onCreate()


    /**
    * Load level config
    *
    */
    public function load (cfg:TLevelCfg, num:Int = -1) : Void {
        this.cfg = cfg;
        this.num = num;

        this.deadline.value = this.deadline.max = this.cfg.deadline;
        this.featuresLeft   = this.cfg.features;
        Level.speed         = Main.cfg.speed * this.cfg.speed;

        this.project.load( Project.rnd(this.cfg.complexity) );
    }//function load()


    /**
    * Start game
    *
    */
    public function start () : Void {
        this.next = this._getNextFeature();
        //drop first feature
        this.nextFeature();

        //start deadline timer
        this.deadline.tween(this.cfg.deadline, {value:0}).onComplete(this.gameOver);
    }//function start()


    /**
    * Pause game
    *
    */
    public function pause () : Void {
        this.stopped = true;
        Actuate.pauseAll();
    }//function pause()


    /**
    * Resume game
    *
    */
    public function resume () : Void {
        this.stopped = false;
        Actuate.resumeAll();
    }//function resume()


    /**
    * Create next feature
    *
    */
    public function nextFeature () : Void {
        if( this.stopped ) return;
        if( this.featuresLeft < 0 ){
            this.victory();
            return;
        }
        this.featuresLeft --;

        this.current = this.next;

        //Feature.rnd(3);
        this.field.addChild(this.current);
        if( this.featuresLeft > 0 ){
            this.next    = this._getNextFeature();
            this.displayNext.addChild(this.next);
        }

        this.current.top  = 0;
        this.current.left = this.current.col * Main.cfg.block.size;
        this.current.step();
    }//function nextFeature()


    /**
    * Generate next feature according to complexity level
    *
    */
    private function _getNextFeature () : Feature {
        return UIBuilder.create(Feature, {
            blocks : Main.structs[Std.random(
                this.cfg.complexity < 8
                    ? 8
                    : (this.cfg.complexity <= Main.structs.length ? this.cfg.complexity : Main.structs.length)
            )]
        });
    }//function _getNextFeature()


    /**
    * Drop current feature
    *
    */
    public function dropFeature () : Void {
        if( this.current.dropped /* || this.current.row <= 0 */) return;
        if( this.current.actuateTimer != null ){
            Actuate.stop(this.current.actuateTimer, null, false, false);
            this.current.actuateTimer = null;
        }

        this.current.dropped = true;
        while( this.current.canMove() ){
            this.current.row ++;
        }
        this.current.row --;
        this.current.performStep();
    }//function dropFeature()


    /**
    * Called when feature was stopped. Add feature's blocks to project
    *
    */
    public function featureStopped (f:Feature) : Void {
        //game over
        if( f.row <= 0 ){
            this.gameOver();

        //next feature
        }else{
            this.project.addFeature(f);
            this.nextFeature();
            f.free();
        }
    }//function featureStopped()


    /**
    * Game over
    *
    */
    public function gameOver () : Void {
        this.stopped = true;
        this.deadline.tweenStop();
        UIBuilder.buildFn("ui/popup/gameOver.xml")().show();
    }//function gameOver()


    /**
    * Victory!
    *
    */
    public function victory () : Void {
        this.stopped = true;
        this.deadline.tweenStop();
        UIBuilder.buildFn("ui/popup/victory.xml")().show();
    }//function victory()


    /**
    * Try to rotate feature
    * @param left - rotate left(true) or right(false)
    *
    */
    public function rotateFeature (left:Bool) : Void {
        //rotating is disabled
        return;
        this.current.rotate(left);
    }//function rotateFeature()


/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

    /**
    * Setter `featuresLeft`.
    *
    */
    private inline function set_featuresLeft (featuresLeft:Int) : Int {
        if( this.featuresLeftLabel != null ){
            this.featuresLeftLabel.text = Std.string(this.featuresLeft);
        }
        return this.featuresLeft = featuresLeft;
    }//function set_featuresLeft

}//class Level