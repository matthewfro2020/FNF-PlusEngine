package options;

/**
 * Submenu for modcharting-related options.
 * Allows users to configure settings that affect modchart performance and quality.
 */
class ModchartingOptionsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Modcharting Settings';
		rpcTitle = 'Modcharting Options Menu'; // for Discord Rich Presence

		// Enable Modcharting option
		var option:Option = new Option('Enable Modcharting',
			'Enables the modcharting system.\n(Disabling improves performance)',
			'enableModcharting',
			BOOL);
		addOption(option);

		// Hold Subdivisions option
		var option:Option = new Option('Hold Subdivisions',
			'Subdivides hold/sustain tails for smoother visuals.\nHigher values improve quality but can hurt performance.\n(Recommended: 4-8)',
			'holdSubdivisions',
			INT);
		option.scrollSpeed = 1;
		option.minValue = 1;
		option.maxValue = 32;
		option.changeValue = 1;
		option.decimals = 0;
		option.showCondition = function() return ClientPrefs.data.enableModcharting;
		addOption(option);

		super();
	}
}