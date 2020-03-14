local preferenceHandler=require "helperScripts.preferenceHandler"

local textResource = {}
	--font sizes
	textResource.fontXS=20
	textResource.fontS=25
	textResource.fontM=30		
	textResource.fontL=40
	textResource.fontXL=60

	--urls
	textResource.twitterUrl="https://twitter.com/famous_dogg"
	textResource.googlePlayUrl="https://play.google.com/store/apps/details?id=com.famousdoggstudios.bt"
	textResource.websiteUrl="https://www.famousdoggstudios.com"

	--debug toast
	textResource.debugToast="This is a debug toast. If you see this toast make sure you remove it from the respective script."

	--data error
	textResource.levelDataError="DATA ERROR- Please relaunch the app."
	textResource.backButtonExitToast="Press again to exit" 
	textResource.notLoggedIn="User not logged in. Please check your internet connection."
	textResource.scoreSubmissionFailure="Best Time could not be submitted. Please check your internet connection."

	--share message
	textResource.shareMessage="Check out “Ball at Work” for some crazy bouncing action in the office with challenging gameplay & fun physics!"

	--reward codes
	textResource.getSlipsFromNotification="Bonus Slips received!"

	--main menu
	textResource.InsufficientTextToast="Please enter at least 10 characters."

	--tutorial menu
	textResource.tutorialTitle="TUTORIAL"
	textResource.tutorial1="Hold down the left or right side of the screen to move the ball in that direction."
	textResource.tutorial2="Get the ball to its goal which is indicated by a bouncing marker."
	textResource.tutorial3="Control options and other settings can be changed in the Pause menu."
	textResource.tutorial4="If you are stuck at any point in a level, tap the restart button to go again."
	textResource.tutorial5="Keep an eye out for useful hints which are displayed on monitors and wall-projections."
	textResource.tutorial6="Tap on the path button to unlock the path-guide for any level."
	textResource.tutorial7="Objects that are accompanied by this icon do not allow the ball to bounce!"

	--exit dialog
	textResource.yesButtonText="YES"
	textResource.noButtonText="NO"
	textResource.exitMenuTitle="ARE YOU SURE?"
	textResource.exitMessage="Do you really want to exit?"

	--settings menu
	textResource.settingsMenuTitle="SETTINGS"

	--pause menu
	textResource.pauseMenuTitle="PAUSED"
	textResource.volume="VOLUME"
	textResource.controls="CONTROLS"
	textResource.resumeButtonText="RESUME"

	--game win/lose menu
	textResource.gameWinMenuTitle="WINNER"
	textResource.timeText="TIME - "
	textResource.gameLoseMenuTitle="GAME OVER"
	textResource.nextButtonText="NEXT\nLEVEL"

	--update menu
	textResource.updateMenuTitle="ERROR"
	textResource.updateButtonText="UPDATE"
	textResource.updateMenuMsg="App version too low. Please update to continue."

	--unlcok menu
	textResource.unlockMenuTitle="NOW AVAILABLE"
	textResource.ballUnlockedMessage="NEW BALL UNLOCKED!"
	textResource.ballLockedToast="Unlocks after completing Level "
	textResource.useNowText="USE NOW"

	--levels Menu
	textResource.levelsMenuTitle="LEVELS"
	textResource.ballSkinMenuTitle="SKINS"

	--leaderboards menu
	textResource.leaderboardTitle="LEADERBOARDS"
	textResource.cancelButtonText="CANCEL"
	textResource.waitDialogTitle="FETCHING SCORES"
	textResource.scoresMenuTitle="SCORES"
	textResource.yourBest="YOUR BEST"
	textResource.name="NAME : "
	textResource.rank="RANK : "

	--get slip menu
	textResource.get10slips="GET 10 SLIPS"
	textResource.get20slips="GET 20 SLIPS"
	textResource.get50slips="GET 50 SLIPS"
	textResource.noAds="No Ads"

	--watchAd Dialog
	textResource.watchAdMenuTitle="BONUS SLIPS"
	textResource.watchAdMessage="Watch an ad for a FREE Bonus Slip."

	--purchase relate texts
	textResource.prohibitedAppText="Prohibited app found on device. Action is blocked"
	textResource.purchaseGreeting="Thanks for your purchase!"

	--skip level menu
	textResource.skipButtonText="SKIP\nLEVEL"
	textResource.skipMenuTitle="SKIP LEVEL"
	textResource.slipsRequiredText="SLIPS REQUIRED"
	textResource.availableSlipsText="AVAILABLE SLIPS"
	textResource.requiredSlipsText="REQUIRED SLIPS"
	textResource.freeSlipText="FREE 1x SLIP"
	textResource.freeText="FREE"
	textResource.insufficientSlipsText="Insufficient slips!"
	textResource.bonusSlipReceived="Bonus Slip Received!"

	--unlock path menu
	textResource.unlockPathMenuTitle="UNLOCK PATH"
	textResource.useButtonText="USE"

	--userFeedback menu
	textResource.userFeedbackMenuTitle="USER FEEDBACK"
	textResource.feedbackRequest="Please share your thoughts on the game. Feedback is anonymous."
	textResource.submitButtonText="SUBMIT"
	textResource.laterButtonText="LATER"

	--rate menu
	textResource.rateButtonText="RATE"
	textResource.rateMenuTitle="RATE US!"
	textResource.rateMessage="Please take a moment to rate the game."
	textResource.messageSuccessToast="Thanks for your valuable feedback!"

	--controls menu
	textResource.levelText="LEVEL "
	textResource.blankTime="-- --"
	textResource.bestText="BEST"

	--buttons text
	textResource.okButtonText="OK"

	--general purpose toasts
	textResource.adNotAvailableToast="Ad could not be fetched"

return textResource