package ld26;

import haxe.Timer;
import motion.Actuate;
import ru.stablex.ui.widgets.Widget;



/**
* Level instance
*
*/
class Level extends Widget{

    //game field
    public var field : Widget;
    //features to implement
    public var features : Array<Feature>;
    //player's project
    public var project : Project;


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
        this.field   = this.getChild("field");
        this.project = this.field.getChildAs("project", Project);
    }//function onCreate()


    /**
    * Load level config
    *
    */
    public function load (data:TLevelCfg = null) : Void {

    }//function load()


    /**
    * Start game
    *
    */
    public function start () : Void {
        //drop first feature
        this.nextFeature();
    }//function start()


    /**
    * Pause game
    *
    */
    public function pause () : Void {
        Actuate.pauseAll();
    }//function pause()


    /**
    * Resume game
    *
    */
    public function resume () : Void {
        Actuate.resumeAll();
    }//function resume()


    /**
    * Drop next feature
    *
    */
    public function nextFeature () : Void {
        var f = Feature.rnd();
        this.field.addChild(f);

        f.step();
    }//function nextFeature()


    /**
    * Called when feature was stopped. Add feature's blocks to project
    *
    */
    public function featureStopped (f:Feature) : Void {
        this.project.addFeature(f);
        this.nextFeature();
    }//function featureStopped()

/*******************************************************************************
*       GETTERS / SETTERS
*******************************************************************************/

}//class Level