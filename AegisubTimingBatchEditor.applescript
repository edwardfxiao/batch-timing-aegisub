set folderPath to choose folder with prompt "Select the folder containing the items to process:"

set timingDirectionList to {"Forward", "Backward"}
set defaultTimingDirectionOption to "Forward"
set promptMessage to "Please select a timing direction:"

try
	set selectedOption to choose from list timingDirectionList with prompt promptMessage default items defaultTimingDirectionOption with title "Select Option" OK button name "Confirm" cancel button name "Cancel"
	if selectedOption is false then
		-- User clicked Cancel
		error number -128
	else
		-- User made a selection
		set selectedOption to item 1 of selectedOption
		log "User selected: " & selectedOption
		
		-- You can now use the selectedOption variable in your script
		set direction to selectedOption
	end if
on error errorMessage number errorNumber
	if errorNumber is -128 then
		-- This is our cancel error
		display dialog "Process cancelled by user." buttons {"OK"} default button "OK"
		return
	else
		-- This is some other error
		display dialog "An error occurred: " & errorMessage buttons {"OK"} default button "OK"
		return
	end if
end try

set timingString to text returned of (display dialog "Please enter a value:" default answer "0:00:00.00" buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel")

if timingString is "" then
	display dialog "No input provided. The process will be cancelled." buttons {"OK"} default button "OK"
	error number -128
end if

set numberString to ""

repeat with i from 1 to length of timingString
	set currentChar to character i of timingString
	if currentChar is in "0123456789" then
		set numberString to numberString & currentChar
	end if
end repeat


set appName to "Aegisub"
set shiftTimeWindowName to "Shift Times"
set shiftTimeWindowConfirmButtonName to "OK"
set shiftTimeMenuItemName to "Shift Times..."
set menuBarItemName to "Timing"

-- Get all items in the folder
tell application "Finder"
	set itemList to every file of folderPath
	set totalItems to count of itemList
end tell

repeat with i from 1 to totalItems
	set currentItem to item i of itemList
	set isLastItem to (i = totalItems)
	set itemPath to (POSIX path of (currentItem as alias))
	tell application appName
		activate
		open itemPath
		tell application "System Events"
			tell process appName
				
				click menu item shiftTimeMenuItemName of menu menuBarItemName of menu bar item menuBarItemName of menu bar 1
				
				repeat until (exists window shiftTimeWindowName)
					delay 0.1
				end repeat
				
				tell window shiftTimeWindowName
					tell text field 1
						set focused to true
						keystroke (ASCII character 28)
						repeat with num from 1 to length of numberString
							set currentNumber to character num of numberString
							keystroke currentNumber
							delay 0.1 -- Optional: add a small delay between key presses
						end repeat
						delay 0.1
					end tell
				end tell
				
				click radio button direction of window shiftTimeWindowName
				delay 0.1
				
				
				if exists button shiftTimeWindowConfirmButtonName of window shiftTimeWindowName then
					click button shiftTimeWindowConfirmButtonName of window shiftTimeWindowName
				end if
				
				repeat
					if not (exists window shiftTimeWindowName) then
						exit repeat
					end if
					delay 0.1
				end repeat
				
				--command + S(1) to save
				key code 1 using {command down}
				delay 0.1
				
			end tell
		end tell
		
		delay 0.1
		
		log (i as string) & " / " & (totalItems as string)
		
		if isLastItem then
			quit
		end if
		
	end tell
	-- Optional: Add a small delay between processing items
	delay 0.1
end repeat

display dialog "Processing complete!" buttons {"OK"} default button "OK"