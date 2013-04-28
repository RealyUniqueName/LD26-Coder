package ld26;

import nme.events.Event;
import nme.media.SoundChannel;
import ru.stablex.Assets;
import ru.stablex.ui.UIBuilder;




/**
* Sound manageer
*
*/
class Sfx {
    //current theme
    static public var theme  : String = "theme";
    //description
    static private var _theme : SoundChannel;

/*******************************************************************************
*       STATIC METHODS
*******************************************************************************/


    /**
    * Start sound
    *
    */
    static public function play (snd:String, showBossSpeech:Bool = false) : Null<SoundChannel> {
        var snd = Assets.getSound(
            #if flash
                "assets/snd/" + snd + ".mp3"
            #else
                "assets/snd/" + snd + ".wav"
            #end
        );
        //show boss speech
        if( showBossSpeech ){
            var level = UIBuilder.getAs("level", Level);

            if( level != null ){
                level.fckBoss.visible = true;
                level.fckBoss.tween(0.5, {alpha:0}).delay(1.5).onComplete(function(){
                    level.fckBoss.alpha = 1;
                    level.fckBoss.visible = false;
                });
            }
        }
        //no sound found
        if( snd == null ) return null;

        return snd.play();
    }//function play()


    /**
    * Start playing provided theme
    *
    */
    static public inline function playTheme (theme:String) : Void {
        Sfx.theme = theme;
        Sfx.stopTheme();
        Sfx.startTheme();
    }//function playTheme()


    /**
    * Start soundtrack
    *
    */
    static public function startTheme (e:Event = null) : Void {
        if( Sfx._theme != null ) {
            Sfx._theme.removeEventListener(Event.SOUND_COMPLETE, Sfx.startTheme);
        }

        Sfx._theme = Sfx.play(Sfx.theme);
        if( Sfx._theme != null ){
            Sfx._theme.addEventListener(Event.SOUND_COMPLETE, Sfx.startTheme);
        }
    }//function startTheme()


    /**
    * Stop soundtrack
    *
    */
    static public function stopTheme () : Void {
        if( Sfx._theme != null ) {
            Sfx._theme.removeEventListener(Event.SOUND_COMPLETE, Sfx.startTheme);
            Sfx._theme.stop();
        }
    }//function stopTheme()


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

}//class Sfx