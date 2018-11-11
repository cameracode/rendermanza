/*
	Eben Yep's Special Potion No. 337
	Keepin' it like a G' since 1969
	Rendermanza 0.1
	TODO: Assign default renderer, option to tick on an Amb Occ Pass, quick prefix/save render button/passes etc.
	http://www.kxcad.net/autodesk/Autodesk_MAXScript_Reference_9/mental_ray_renderer_RendererClass.htm
*/

MacroScript Rendermanza category: "Rendermanza 0.1"
(
	if (( Floater != undefined) and ( Floater.isdisplayed)) do
	(destroyDialog Floater ) -- test if dialog exist

	/* Function Declarations */
	function checkRender nSearch = -- function check if render installed
	(
		theRenderer = for obj in RendererClass.classes where \
		(matchPattern (obj as string) pattern:nSearch) -- check if the name in nSearch variable exist
		
		collect obj
		
		if theRenderer.count ==1
		then renderers.current = theRenderer[1]()
		else
			(messageBox "Render package/plugin not installed! Please check to see if the package/plugin is installed.")
	)

	/* When Scene File is saved, will save last render via callbacks */
	function saveLastRender =
	(
		cbArray = callbacks.notificationParam()
		savePfad = getFilenamePath cbArray[2]
		saveFile = filenameFromPath cbArray[2]
		saveFileName = getFilenameFile cbArray[2]
		if cbArray[1] == 1 then
		(
			build = GetLastRenderedImage copy:false
			if build != undefined then
			(	
				wipPfad = savePfad + "wip/"	
				makeDir wipPfad all:true
				
				build.filename = wipPfad + saveFileName + ".png"
				save build
				close build				
			)
			else
			(
				wipPfad = savePfad + "wip/"	
				makeDir previewPfad all:true
							
				viewport_build = gw.getViewportDib()
				viewport_build.filename = previewPfad + saveFileName + ".png"
				save viewport_build
				close viewport_build
			)	
		)
	)

	callbacks.removeScripts id:#PreviewToMaxfile
	callbacks.addScript #filePreSaveProcess "saveLastRender()" id:#PreviewToMaxfile

	function findRenderer array = 
	(
		for o in RendererClass.classes do append array (o as string)
	)

	/******************************************************************/
	rollout renderOptions "Render Options: "
	(
		group "Current Render Info"
		(
			editText text_rendererActive text:(renderers.current as string) width:175 height:18 align:#center readOnly:true
			editText text_outputSize text:((renderWidth as string) + " x " + (renderHeight as string)) width:175 height:18 align:#center readOnly:true
		)
		
		/* define change render dropDownList */
		/* TODO: Convert to drop-list selection in the future for UI consolidation */
		dropDownList dd_renderer "Assign Renderer: " width:175 height:12 items:#() align:#center
		
		on renderOptions open do
		(
			local nRenderer = #()
			findRenderer nRenderer
			dd_renderer.items = nRenderer
		)
		
		on dd_renderer selected item do 
		(
			renderers.current = RendererClass.classes[item]()
			text_rendererActive.text=(renderers.current as string)
		)
		
		group "Render Output Size: "
		(
			/* TODO: Add more commonly used presets like 2k/4k/6k */
			button btn_1080p "1920x1080" width:60 across:2 align:#center tooltip:"Sets render output to 1920x1080"
			button btn_720p "1280x720" width:60 tooltip:"Sets render output to 1280x720"
			button btn_480p "480x270" width:60 across:2 align:#center tooltip:"Sets render output to 480x720"
			button btn_320p "320x180" width:60 tooltip:"Sets render output to 320x180"
			spinner spn_width "Width:  " range:[0,6000,0] fieldwidth: 40 across:2 align:#center 
			spinner spn_height "Height: " range:[0,6000,0] fieldwidth:40
		)
	
		on btn_1080p pressed do
		(
			renderWidth =	1920
			renderHeight = 1080
			--outputSize = btn_1080p.value
			print outputSize
		)
		
		on btn_720p pressed do
		(
			renderWidth =	1280
			renderHeight = 720
		)
		
		on btn_480p pressed do
		(
			renderWidth =	480
			renderHeight = 270
		)
		
		on btn_320p pressed do
		(
			renderWidth =	320
			renderHeight = 180
		)
		
		on spn_width changed value do
		(

		)
		
		on spn_height changed value do
		(

		)
	)
	
	rollout renderOutput "Render Output: "
	(
		group "Output File Name: " 
		(
			editText edOutputFileName "" fieldWidth:175 offset:[-8,0] across:2 align:#left
			button btn_outputFileBrowse "..." width:17 height:17 offset:[6,0] align:#right tooltip:"Select base output path"
		)
		
		on btn_outputFileBrowse pressed do 
		(
			local dir = getSavePath caption:"Select output folder..." initialDir:(getFilenameFile edOutputFileName.text)
			if dir != undefined then 
			(
				-- Keep old sub-folders using parameter names and replace only the base constant folders.
				local fileName = filenameFromPath edOutputFileName.text
				local oldDirParts = filterString (getFilenamePath edOutputFileName.text) "\\/"
				for p in oldDirParts where matchPattern p pattern:"*{*}*" do
				dir += "\\" + p
				dir += "\\"
				-- Assign the new folder to the edit text control.
				edOutputFileName.text = dir + fileName
			)
		)
			
		group "Render: "
		(
			label lbl_mentalJazz "Enables some MR Goodness:"
			checkbutton cbtn_mentalJazz "MR Jazz" width:160 tooltip:"MR Jazz: Sets Filter type to Mitchell, and sets the samples per pixel to Minimum: 4 Maximum: 16"
			label lbl_stdRender "Standard Rendering: "
			button btn_saveWIP "Save WIP" width:60 height:60 align:#center across:2
			button btn_render "Render" width:60 height:60
			button btn_renderSceneDialog "Render Scene Dialog" width:160 tooltip:"Opens default Render Scene Dialog"
		)
		
		on cbtn_mentalJazz changed state do
		(
			delete $lights/RS_*
			if state == on then
			(
				renderers.current = Mental_Ray_Renderer filter:3 MinimumSamples: 1 MaximumSamples: 2
			)
			else
			(
				renderers.current = Mental_Ray_Renderer()
			)
		)
			
		on btn_render pressed do 
		(
			-- Execute the render
			max quick render
		)
		
		on btn_saveWIP pressed do
		(

		)
		
		on btn_renderSceneDialog pressed do 
		(	
			renderSceneDialog.Open()
		)
	)
		
	
	Floater = newRolloutFloater "Rendermanza 0.1" 230 515 150 150
	addRollout renderOptions Floater
	addRollout renderOutput Floater
)