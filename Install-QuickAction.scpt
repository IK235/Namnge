on run
	set quickActionFolder to (path to library folder from user domain as text) & "Services:"

	tell application "Finder"
		if not (exists folder quickActionFolder) then
			make new folder at (path to library folder from user domain) with properties {name:"Services"}
		end if
	end tell

	display dialog "Quick Action installation guide:

1. Open Automator (Applications > Automator)
2. Create a new 'Quick Action'
3. Set:
   - Workflow receives: files or folders
   - in: Finder
4. Add action: 'Run AppleScript'
5. Paste this code:

on run {input, parameters}
	set appPath to \"/Applications/QuickRename.app\"
	tell application appPath
		activate
		open input
	end tell
	return input
end run

6. Save as: 'Rename with QuickRename'
7. Right-click any file in Finder > Services > Rename with QuickRename" buttons {"OK"} default button 1
end run
