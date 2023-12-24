#if sys
package;

using StringTools;

class Argument
{
	public static function parse(args:Array<String>):Bool
	{
		switch (args[0])
		{
			default:
			{
				return false;
			}

			case '-h' | '--help':
			{
				var exePath:Array<String> = Sys.programPath().split(#if windows '\\' #else '/' #end);
				var exeName:String = exePath[exePath.length - 1].replace('.exe', '');

				Sys.println('
Usage:
  ${exeName} (menu | story | freeplay | credits | options)
  ${exeName} play "Song Name" [-s | --story] [-d=<val> | --diff=<val>]
  ${exeName} chart "Song Name" [-d=<val> | --diff=<val>]
  ${exeName} debug
  ${exeName} character <char>
  ${exeName} (firstboot | gallery | sticker | costume | thankyou)
  ${exeName} -h | --help

Options:
  -h       --help        Show this screen.
  -s       --story       Enables story mode when in play state.
  -d=<val> --diff=<val>  Sets the difficulty for the song. [default: normal]
');

				Sys.exit(0);
			}

			case 'menu':
			{
				LoadingState.loadAndSwitchState(new MainMenuState());
			}

			case 'story':
			{
				LoadingState.loadAndSwitchState(new DokiStoryState());
			}

			case 'freeplay':
			{
				LoadingState.loadAndSwitchState(new DokiFreeplayState());
			}

			case 'credits':
			{
				LoadingState.loadAndSwitchState(new CreditsState());
			}

			case 'options':
			{
				LoadingState.loadAndSwitchState(new OptionsState());
			}

			case 'play':
			{
				var modFolder:String = null;
				var diff:String = null;
				for (i in 2...args.length)
				{
					if (args[i] == '-s' || args[i] == '--story')
						PlayState.isStoryMode = true;

					else if (args[i].startsWith('-d=') || args[i].startsWith('--diff='))
						diff = (args[i].split('='))[1];

					else if (modFolder != null)
						modFolder = args[i];
				}

				setupSong(args[1], diff);
				LoadingState.loadAndSwitchState(new PlayState(), true);
			}

			case 'chart':
			{
				var modFolder:String = null;
				var diff:String = null;
				for (i in 2...args.length)
				{
					if (args[i].startsWith('-d') || args[i].startsWith('--diff'))
						diff = (args[i].split('='))[1];

					else if (modFolder != null)
						modFolder = args[i];
				}

				setupSong(args[1], diff);
				LoadingState.loadAndSwitchState(new ChartingState(), true);
			}

			case 'character':
			{
				LoadingState.loadAndSwitchState(new AnimationDebugState(args[1]));
			}

			// DDTO+ specific
			case 'firstboot':
			{
				LoadingState.loadAndSwitchState(new FirstBootState());
			}

			case 'gallery':
			{
				LoadingState.loadAndSwitchState(new GalleryArtState());
			}

			case 'sticker':
			{
				LoadingState.loadAndSwitchState(new GalleryStickerState());
			}

			case 'costume':
			{
				LoadingState.loadAndSwitchState(new CostumeSelectState());
			}

			case 'thankyou':
			{
				LoadingState.loadAndSwitchState(new ThankyouState());
			}
		}

		return true;
	}

	static function setupSong(songName:String, ?diff:String):Void
	{
		var defaultDiff:Bool = diff == null || (diff != null && diff.toLowerCase().trim() == 'normal');
		var jsonName:String = songName + (!defaultDiff ? '-${diff}' : '');

		var diffFormat:String = diff.toLowerCase().trim();
		PlayState.storyDifficulty = diffFormat == 'hard' ? 2 : diffFormat != 'easy' ? 1 : 0;

		PlayState.SONG = Song.loadFromJson(jsonName, songName);
	}
}
#end
