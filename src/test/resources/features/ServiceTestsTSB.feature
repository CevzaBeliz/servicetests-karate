Feature: ServiceTests

  Background:
    * url 'https://dev-api.ligabet.com/'
    * configure ssl = true
   # * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json'}
    * def req = read('classpath:requests.json')


    #Create token with signature
    #* path '/api/auth/token'
    #* header ClientId = 'Testinium-Cloud'
    #* header Nonce = 'asdewq'
    #* header Signature = 'FE9540106B63F5FB644A46554AB97310E820B764765F407065ECC5933A40AF9B'
    #* method Get
    #* status 200
    #* def token = response.token
    * def token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJUZXN0aW5pdW0tQ2xvdWQiLCJqdGkiOiJlMWYyMTdhOS02NjI1LTRkMjAtYTQyOS1mYWE2N2QxN2I1ZmQiLCJlbWFpbCI6ImJ1Z3JhLnVja3VzQGxpZ2FzdGF2b2sucnUiLCJnaXZlbl9uYW1lIjoiVGVzdGluaXVtLUNsb3VkIiwiSWRlbnRpdHlJZCI6IjI3IiwiQW5vbnltb3VzIjoiMjM1NDIiLCJDbGllbnRJZCI6ImNsb3VkIiwiZXhwIjoxNjY1NTg2MzY3LCJpc3MiOiJodHRwOi8vaXNzdWVyLmF0IiwiYXVkIjoiaHR0cDovL2F1ZGllbmNlLmF0In0.x7C19lzTJed2DIrSx1RpITsdZRz3Zp7GD-Fhw-z3t0U'
    * print token

    #Definition of sign param for specific user from json file used for Generate Session Token Method
    * def Sign = req.signTSB

    # Generate Non-Anonymous Session Token
    Given path '/api/data/user/signin'
    And header Authorization = 'Bearer ' + token
    And request Sign
    When method Post
    Then status 200
    * def session = response.sessionToken
    Then print session
    And header Session = session

    #Defining the user informations to be used in the request body defined as "placebet"
    * def branchId = $.user.branch.id
    * print ("branchId: " + branchId)
    * def accountId = $.user.mainAccount.id
    * print ("accountId: "+ accountId)
    * def userId = $.user.profile.id
    * print ("userId: " +userId)
    * def currencyId = $.user.mainAccount.currencyId
    * print ("currencyId: " + currencyId)
    * def balance = $.user.mainAccount.balance
    * print ("balance: " + balance)

  @BonusServiceTestTSB
  Scenario: Bonus Service Test
    # User Bonus {0: Always Ask, 1: Always Accept 2: Never Accept}
    #-------------------------------------------------------------------
    # User Bonus Code
    And path '/api/data/bonus/settings'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    #-------------------------------------------------------------------
    # Definition of Always Accept option used for Change Bonus method
    * def Bonus_1 = req.Bonus_1
    # Change Bonus
    And path '/api/data/bonus/settings'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request Bonus_1
    When method Post
    Then status 200

    #-------------------------------------------------------------------
    # Check Bonus Change
    And path '/api/data/bonus/settings'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    Then match $.bonusAcceptance == 1

    # Definition of Always ASK option used for Set Default method
    * def Bonus_2 = req.Bonus_2
    # Set Default
    And path '/api/data/bonus/settings'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request Bonus_2
    When method Post
    Then status 200

  @BetSettingsServiceTestTSB
  Scenario: Change the bet settings for a user
    #Get the bet settings
    * path '/api/data/usersettings/bet'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    # parameters for changing bet settings
    * def betparameters = req.betparameters
    #Change the bet settings
    And path '/api/data/usersettings/bet/save'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request betparameters
    When method Post
    Then status 200

    #Verify that the bet settings are the same with settled settings
    * path '/api/data/usersettings/bet'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    Then match $.defaultStake == 8.5
    Then match $.oddValueChangeHandling == 0
    Then match $.cashoutAmountChangeHandling == 1

    #Reset the items to prepare the next test
    * def resetbetparameters = req.resetbetparameters
    # Save method to reset the bet settings
    # In this way easy to check the settings again
    And path '/api/data/usersettings/bet/save'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request resetbetparameters
    When method Post
    Then status 200

    #Verify that the bet settings are the same with settled settings
    * path '/api/data/usersettings/bet'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    Then match $.defaultStake == 15
    Then match $.oddValueChangeHandling == 1
    Then match $.cashoutAmountChangeHandling == 2

    #Get the default bet settings, this setting is settled if the user doesn't set any default stake
    * path '/api/data/bet/settings'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    Then match $.defaultStake == 100

  @MaxSessionTimeServiceTestTSB
  Scenario: Get and set the user defined security settings without sms and mail query

    #Get the security max session time informations
    And path '/api/data/usersettings/security'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Security max session parameters to set time-limit
    * def setmaxses = req.setmaxses

    #Set the security/ maxsession time limit
    And path '/api/data/usersettings/security'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request setmaxses
    When method Post
    Then status 200

    #Save the last time the user accept to set the time-limit
    And path '/api/data/usersettings/maxsessiontimelimit/save'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request ''
    When method Post
    Then status 200

    #Get the time when user accepts the continuation of current session
    And path '/api/data/usersettings/maxsessiontimelimit'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Check to security max session time
    And path '/api/data/usersettings/security'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    Then match $.maxSessionTime == 30

    #Security max session parameters to reset time-limit
    * def resetmaxses = req.resetmaxses

    #Reset the security/ maxsession time
    And path '/api/data/usersettings/security'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request resetmaxses
    When method Post
    Then status 200

    #Check to security max session after reset
    And path '/api/data/usersettings/security'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    Then match $.maxSessionTime == 75

  @GetSelfLimitTSB
    Scenario: Get selflimit info for user
     And path '/api/data/usersettings/selflimits'
     And header Authorization = 'Bearer ' + token
     And header Session = session
     When method Get
     Then status 200

  @SelflimitsServiceTestsTSB
    Scenario: Updating the SelfLimits while checking and saving the values
      #This methot for the checking value which enter the selflimit field
      #If this value not ok for requirement, this method will fail
      And path '/api/data/usersettings/selflimits/check'
      * def x = call read('ServiceTestsTSB.feature@GetSelfLimitTSB')
      * def response = x.response
      #Defining to selflimit settings from the GetSelfLimit method's values
      #Defined as one value less than the existing selflimit's value
      * def maximumStakePerDay = $.maximumStakePerDay
      * print 'maximumStakePerDay: ', maximumStakePerDay
      * def newMaximumStakePerDay = maximumStakePerDay - 1
      * print 'newMaximumStakePerDay: ', newMaximumStakePerDay

      * def maximumStakePerWeek = $.maximumStakePerWeek
      * print 'maximumStakePerWeek: ', maximumStakePerWeek
      * def newMaximumStakePerWeek = maximumStakePerWeek - 1
      * print 'newMaximumStakePerWeek: ', newMaximumStakePerWeek

      * def maximumStakePerMonth = $.maximumStakePerMonth
      * print 'maximumStakePerMonth: ', maximumStakePerMonth
      * def newMaximumStakePerMonth = maximumStakePerMonth - 1
      * print 'newMaximumStakePerMonth: ', newMaximumStakePerMonth

      * def maximumLossPerDay = $.maximumLossPerDay
      * print 'maximumLossPerDay: ', maximumLossPerDay
      * def newMaximumLossPerDay = maximumLossPerDay - 1
      * print 'newMaximumLossPerDay: ', newMaximumLossPerDay

      * def maximumLossPerWeek = $.maximumLossPerWeek
      * print 'maximumLossPerWeek: ', maximumLossPerWeek
      * def newMaximumLossPerWeek = maximumLossPerWeek - 1
      * print 'newMaximumLossPerWeek: ', newMaximumLossPerWeek

      * def maximumLossPerMonth = $.maximumLossPerMonth
      * print 'maximumLossPerMonth: ', maximumLossPerMonth
      * def newMaximumLossPerMonth = maximumLossPerMonth - 1
      * print 'newMaximumLossPerMonth: ', newMaximumLossPerMonth

      And header Authorization = 'Bearer ' + token
      And header Session = session
      #Set the self limits as "selflimitcheck" request body according to the value which is defined earlier
      * def selflimitcheck = req.selflimit
      * set selflimitcheck $.maximumStakePerDay = newMaximumStakePerDay
      * set selflimitcheck $.maximumStakePerWeek = newMaximumStakePerWeek
      * set selflimitcheck $.maximumStakePerMonth = newMaximumStakePerMonth
      * set selflimitcheck $.maximumLossPerDay = newMaximumLossPerDay
      * set selflimitcheck $.maximumLossPerWeek = newMaximumLossPerWeek
      * set selflimitcheck $.maximumLossPerMonth = newMaximumLossPerMonth
      * request selflimitcheck
      When method Post
      Then status 200
      * match $.ok == true

      #Save the defined values from "selflimitcheck" request
      And path '/api/data/usersettings/selflimits/save'
      And header Authorization = 'Bearer ' + token
      And header Session = session
      * def selflimitsave = req.selflimit
      * set selflimitsave $.maximumStakePerDay = newMaximumStakePerDay
      * set selflimitsave $.maximumStakePerWeek = newMaximumStakePerWeek
      * set selflimitsave $.maximumStakePerMonth = newMaximumStakePerMonth
      * set selflimitsave $.maximumLossPerDay = newMaximumLossPerDay
      * set selflimitsave $.maximumLossPerWeek = newMaximumLossPerWeek
      * set selflimitsave $.maximumLossPerMonth = newMaximumLossPerMonth
      * request selflimitsave
      When method Post
      Then status 200
      * match $.ok == true

      #Get self limit settings
      * def getselflimits = call read('ServiceTestsTSB.feature@GetSelfLimitTSB')
      * def response = getselflimits.response
      * match newMaximumStakePerDay == $.maximumStakePerDay
      * match newMaximumStakePerWeek == $.maximumStakePerWeek
      * match newMaximumStakePerMonth == $.maximumStakePerMonth
      * match newMaximumLossPerDay == $.maximumLossPerDay
      * match newMaximumLossPerWeek == $.maximumLossPerWeek
      * match newMaximumLossPerMonth == $.maximumLossPerMonth

  @ListofGames
  Scenario: List of available games
    #List the available games with filters
    And path '/api/data/games/search'
    And path pageSize  = '3'
    And path pageNumber  = '7'
    And path langId   = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

  @CashoutSingleBetServiceTestTSB
  Scenario: Cash out the single bet which place the one available game
    # Calling the available games method from the @ListofGames to define the parameters easier
    * def availablegames = call read('ServiceTestsTSB.feature@ListofGames')
    * def response = availablegames.response

    #Defining the game values in the list of available games
    * def gameId = $.items[0].markets[0].gameId
    And print gameId
    * def marketId = $.items[0].markets[0].odds[0].marketId
    And print marketId
    * def oddId = $.items[0].markets[0].odds[0].id
    And print oddId
    * def marketTypeId = $.items[0].markets[0].marketTypeId
    And print marketTypeId
    * def value = $.items[0].markets[0].odds[0].value
    And print value

    #Defining "singleBet" parameter pulled from json file as "placebet"
    * def placebet = req.singleBet
    #--------------------------------------------------
    #Set the individual user information from the response of signin method
    * set placebet $.[0].branchId = branchId
    * set placebet $.[0].accountId = accountId
    * set placebet $.[0].userId = userId
    * set placebet $.[0].currencyId = currencyId
    #--------------------------------------------------
    #The datas which the defined games from list of available games
    And set placebet $.[:1].items[:1].gameId = gameId
    And set placebet $.[:1].items[:1].marketId = marketId
    And set placebet $.[:1].items[:1].oddId = oddId
    And set placebet $.[:1].items[:1].marketTypeId = marketTypeId
    And set placebet $.[:1].items[:1].oddValue = value
    #-----------------------------------------------

    #Place bet method with is settled "placebet" parameters and check that the placed bet id is the same the listed last "betSlipId"
    And path '/api/data/bet/placebets'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request placebet
    When method Post
    Then status 200
    * def betSlipId = $.results[0].betSlipId
    * print betSlipId
    Then match $.results[0].placeResultType == 1

    #List the Bets for the specific user
    And path '/api/data/userbets/paged'
    And path startIndex  = '250'
    And path pageSize  = '200'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def lastBetSlipId = $.items[-1].id
    * print lastBetSlipId
    And match betSlipId == lastBetSlipId

    #Calculate Cashout
    And path '/api/data/bet/calculatecashout'
    And path betId  = lastBetSlipId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    Then match $.calculationResultType == 1
    * def cashoutAmount = $.cashoutAmount
    #--------------------------------------------------
    #Defining "cashoutparam" parameter pulled from json file as "cashoutparam"
    * def cashoutparam = req.cashoutparam
    #--------------------------------------------------
    #Cashout the placed last bet
    And path '/api/data/bet/cashout'
    And path betId  = lastBetSlipId
    * set cashoutparam $.acceptedAmount = cashoutAmount
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request cashoutparam
    When method Post
    Then status 200

    #Verify that responded cashoutResultType value is the one of the cashoutResultTypeList
    # x represents to the succeeded cashouts inside the cashoutResultTypeList
    * def cashoutResultTypeList = req.cashoutResultTypeList
    * print cashoutResultTypeList
    * def expected = $.cashoutResultType
    * print expected
    * match cashoutResultTypeList.x contains '#(^*expected)'

  @CashoutCombiBetServiceTestTSB
  Scenario: Cash out the combi bet which place the 3 available games

     # Call the available games method from the @ListofGames to define the parameters easier
    * def availablegames = call read('ServiceTestsTSB.feature@ListofGames')
    * def responsecombi = availablegames.response
    #--------------------------------------------------
    #Defining the first game values in the list of available games
    * def gameId = responsecombi.items[0].markets[0].gameId
    And print gameId
    * def marketId = responsecombi.items[0].markets[0].odds[0].marketId
    And print marketId
    * def oddId = responsecombi.items[0].markets[0].odds[0].id
    And print oddId
    * def marketTypeId = responsecombi.items[0].markets[0].marketTypeId
    And print marketTypeId
    * def value = responsecombi.items[0].markets[0].odds[0].value
    And print value

    #Defining the second game values in the list of available games
    * def gameId1 = responsecombi.items[1].markets[1].gameId
    And print gameId1
    * def marketId1 = responsecombi.items[1].markets[1].odds[0].marketId
    And print marketId1
    * def oddId1 = responsecombi.items[1].markets[1].odds[0].id
    And print oddId1
    * def marketTypeId1 = responsecombi.items[1].markets[1].marketTypeId
    And print marketTypeId1
    * def value1 = responsecombi.items[1].markets[1].odds[0].value
    And print value1

    #Defining the third game values in the list of available games
    * def gameId2 = responsecombi.items[2].markets[2].gameId
    And print gameId2
    * def marketId2 = responsecombi.items[2].markets[2].odds[0].marketId
    And print marketId2
    * def oddId2 = responsecombi.items[2].markets[2].odds[0].id
    And print oddId2
    * def marketTypeId2 = responsecombi.items[2].markets[2].marketTypeId
    And print marketTypeId2
    * def value2 = responsecombi.items[2].markets[2].odds[0].value
    And print value2
    #--------------------------------------------------
    #Defining "combiBet" parameter pulled from json file as "placebet"
    * def placebet = req.combiBet
    #--------------------------------------------------
    #Set the individual user informations from the response of signin method
    * set placebet $.[0].branchId = branchId
    * set placebet $.[0].accountId = accountId
    * set placebet $.[0].userId = userId
    * set placebet $.[0].currencyId = currencyId
    #--------------------------------------------------
    #Set the datas for first game from first defined available game
    And set placebet $.[0].items[0].gameId = gameId
    And set placebet $.[0].items[0].marketId = marketId
    And set placebet $.[0].items[0].oddId = oddId
    And set placebet $.[0].items[0].marketTypeId = marketTypeId
    And set placebet $.[0].items[0].oddValue = value

    #Set the datas for second game from second defined available game
    And set placebet $[0].items[1].gameId = gameId1
    And set placebet $[0].items[1].marketId = marketId1
    And set placebet $[0].items[1].oddId = oddId1
    And set placebet $[0].items[1].marketTypeId = marketTypeId1
    And set placebet $[0].items[1].oddValue = value1

    #Set the datas for third game from third defined available game
    And set placebet $[0].items[2].gameId = gameId2
    And set placebet $[0].items[2].marketId = marketId2
    And set placebet $[0].items[2].oddId = oddId2
    And set placebet $[0].items[2].marketTypeId = marketTypeId2
    And set placebet $[0].items[2].oddValue = value2
    #--------------------------------------------------
    #Place bet method with is settled "placebet" parameters and check that the placed bet id is the same the listed last "betSlipId"
    And path '/api/data/bet/placebets'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request placebet
    When method Post
    Then status 200
    * def betSlipId = $.results[0].betSlipId
    * print betSlipId
    Then match $.results[0].placeResultType == 1

    #List the Bets for the specific user
    And path '/api/data/userbets/paged'
    And path startIndex  = '250'
    And path pageSize  = '200'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def lastBetSlipId = $.items[-1].id
    * print lastBetSlipId
    And match betSlipId == lastBetSlipId

    #Calculate Cashout
    And path '/api/data/bet/calculatecashout'
    And path betId  = lastBetSlipId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    Then match $.calculationResultType == 1
    * def cashoutAmount = $.cashoutAmount
    #-------------------------------------------------------
    #Defining "cashoutparam" parameter pulled from json file as "cashoutparam"
    * def cashoutparam = req.cashoutparam
    #-------------------------------------------------------
    #Cashout the placed last bet
    And path '/api/data/bet/cashout'
    And path betId  = lastBetSlipId
    * set cashoutparam $.acceptedAmount = cashoutAmount
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request cashoutparam
    When method Post
    Then status 200

    #Verify that responded cashoutResultType value is the one of the cashoutResultTypeList
    # x represents to the succeeded cashouts inside the cashoutResultTypeList
    * def cashoutResultTypeList = req.cashoutResultTypeList
    * print cashoutResultTypeList
    * def expected = $.cashoutResultType
    * print expected
    * match cashoutResultTypeList.x contains '#(^*expected)'

  @PlaceSystemBetServiceTestTSB
  Scenario: Place System Bet
     #List the available games with filters
    And path '/api/data/games/search'
    And path pageSize  = '7'
    And path pageNumber  = '53'
    And path langId   = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Defining the first game values in the list of available games
    * def gameId = $.items[0].markets[0].gameId
    And print gameId
    * def marketId = $.items[0].markets[0].odds[0].marketId
    And print marketId
    * def oddId = $.items[0].markets[0].odds[0].id
    And print oddId
    * def marketTypeId = $.items[0].markets[0].marketTypeId
    And print marketTypeId
    * def value = $.items[0].markets[0].odds[0].value
    And print value

    #Defining the second game values in the list of available games
    * def gameId1 = $.items[1].markets[1].gameId
    And print gameId1
    * def marketId1 = $.items[1].markets[1].odds[0].marketId
    And print marketId1
    * def oddId1 = $.items[1].markets[1].odds[0].id
    And print oddId1
    * def marketTypeId1 = $.items[1].markets[1].marketTypeId
    And print marketTypeId1
    * def value1 = $.items[1].markets[1].odds[0].value
    And print value1

    #Defining the third game values in the list of available games
    * def gameId2 = $.items[2].markets[2].gameId
    And print gameId2
    * def marketId2 = $.items[2].markets[2].odds[0].marketId
    And print marketId2
    * def oddId2 = $.items[2].markets[2].odds[0].id
    And print oddId2
    * def marketTypeId2 = $.items[2].markets[2].marketTypeId
    And print marketTypeId2
    * def value2 = $.items[2].markets[2].odds[0].value
    And print value2

    #Defining the fourth game values in the list of available games
    * def gameId3 = $.items[3].markets[2].gameId
    And print gameId3
    * def marketId3 = $.items[3].markets[2].odds[0].marketId
    And print marketId3
    * def oddId3 = $.items[3].markets[2].odds[0].id
    And print oddId3
    * def marketTypeId3 = $.items[3].markets[2].marketTypeId
    And print marketTypeId3
    * def value3 = $.items[3].markets[2].odds[0].value
    And print value3

    #Parameters to place bet from json file
    * def placebet = req.systemBet
    #--------------------------------------------------
    #Set the individual user information from the response of signin method
    * set placebet $.[0].branchId = branchId
    * set placebet $.[0].accountId = accountId
    * set placebet $.[0].userId = userId
    * set placebet $.[0].currencyId = currencyId
    #--------------------------------------------------
    #The datas from the available games list
    And set placebet $.[0].items[0].gameId = gameId
    And set placebet $.[0].items[0].marketId = marketId
    And set placebet $.[0].items[0].oddId = oddId
    And set placebet $.[0].items[0].marketTypeId = marketTypeId
    And set placebet $.[0].items[0].oddValue = value

    And set placebet $[0].items[1].gameId = gameId1
    And set placebet $[0].items[1].marketId = marketId1
    And set placebet $[0].items[1].oddId = oddId1
    And set placebet $[0].items[1].marketTypeId = marketTypeId1
    And set placebet $[0].items[1].oddValue = value1

    And set placebet $[0].items[2].gameId = gameId2
    And set placebet $[0].items[2].marketId = marketId2
    And set placebet $[0].items[2].oddId = oddId2
    And set placebet $[0].items[2].marketTypeId = marketTypeId2
    And set placebet $[0].items[2].oddValue = value2

    And set placebet $[0].items[3].gameId = gameId3
    And set placebet $[0].items[3].marketId = marketId3
    And set placebet $[0].items[3].oddId = oddId3
    And set placebet $[0].items[3].marketTypeId = marketTypeId3
    And set placebet $[0].items[3].oddValue = value3

    #Place Bet Method
    And path '/api/data/bet/placebets'
    #And path betId  = ''
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request placebet
    When method Post
    Then status 200
    * def betSlipId = $.results[0].betSlipId
    * print betSlipId
    Then match $.results[0].placeResultType == 1

    #List the Bets for the specific user
    And path '/api/data/userbets/paged'
    And path startIndex  = '600'
    And path pageSize  = '200'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def lastBetSlipId = $.items[-1].id
    * print lastBetSlipId
    And match betSlipId == lastBetSlipId

  @PasswordServiceTestTSB
  Scenario: Change Password
    #-------------------------------------------
    # Check password is correct
    Given path '/api/data/user/checkpassword'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param password = 'password1'
    * method Get
    * status 200
    #-------------------------------------------
    # Change password to 'deneme123'
    * path '/api/data/user/changepassword'
    * header Authorization = 'Bearer ' + token
    * header Session = session
    * param oldPassword = 'password1'
    * param newPassword = 'deneme123'
    * request 'oldPassword'
    * request 'newPassword'
    * method Put
    * status 200
    #-------------------------------------------
    # Logout from session
    Given path '/api/data/user/signout'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * request ''
    * method Post
    * status 200
    #-------------------------------------------
    # Create another session with new password
    * def signNewPassword = read('classpath:requests.json')
    * def SignNewPassword = signNewPassword.signTSBNewPassword
    #-------------------------------------------
    # Generate Non-Anonymous Session Token
    Given path '/api/data/user/signin'
    And header Authorization = 'Bearer ' + token
    And header Content-Type = 'application/json; charset=utf-8'
    And  request SignNewPassword
    When method Post
    Then status 200
    * def session_2 = response.sessionToken
    Then print session_2
    And header Session = session_2
    #-------------------------------------------
    # Check password changed correctly
    Given path '/api/data/user/checkpassword'
    And header Authorization = 'Bearer ' + token
    And header Session = session_2
    * param password = 'deneme123'
    * method Get
    * status 200
    #-------------------------------------------
    # Change password to old password
    * path '/api/data/user/changepassword'
    * header Authorization = 'Bearer ' + token
    * header Session = session_2
    * param oldPassword = 'deneme123'
    * param newPassword = 'password1'
    * request 'oldPassword'
    * request 'newPassword'
    * method Put
    * status 200

  @PlaceSameBetsInDifferentSlipTSB
  Scenario: Place Bet More Than One Slip
    * path '/api/data/games/gamesbyleague/54/1'
    * header Authorization = 'Bearer ' + token
    * header Session = session
    * method Get
    * status 200

    #First Bet Items
    #---------------------------------------------
    * def gameId = $.items[0].markets[0].gameId
    * print gameId
    * def marketId = $.items[0].markets[0].odds[0].marketId
    * print marketId
    * def oddId = $.items[0].markets[0].odds[0].id
    * print oddId
    * def marketTypeId = $.items[0].markets[0].marketTypeId
    * print marketTypeId
    * def oddvalue = $.items[0].markets[0].odds[0].value
    * print oddvalue
    #Second Bet Items
    #---------------------------------------------
    * def gameId2 = $.items[1].markets[0].gameId
    * print gameId2
    * def marketId2 = $.items[1].markets[0].odds[0].marketId
    * print marketId2
    * def oddId2 = $.items[1].markets[0].odds[0].id
    * print oddId2
    * def marketTypeId2 = $.items[1].markets[0].marketTypeId
    * print marketTypeId2
    * def oddvalue2 = $.items[1].markets[0].odds[0].value
    * print oddvalue2
    #Third Bet Items
    #---------------------------------------------
    * def gameId3 = $.items[2].markets[0].gameId
    * print gameId3
    * def marketId3 = $.items[2].markets[0].odds[0].marketId
    * print marketId3
    * def oddId3 = $.items[2].markets[0].odds[0].id
    * print oddId3
    * def marketTypeId3 = $.items[2].markets[0].marketTypeId
    * print marketTypeId3
    * def oddvalue3 = $.items[2].markets[0].odds[0].value
    * print oddvalue3
    #Fourth Bet Items
    #---------------------------------------------
    * def gameId4 = $.items[3].markets[1].gameId
    * print gameId4
    * def marketId4 = $.items[3].markets[1].odds[0].marketId
    * print marketId4
    * def oddId4 = $.items[3].markets[1].odds[0].id
    * print oddId4
    * def marketTypeId4 = $.items[3].markets[1].marketTypeId
    * print marketTypeId4
    * def oddvalue4 = $.items[3].markets[0].odds[0].value
    * print oddvalue4

    #Call Bet Slip
    #---------------------------------------------
    * def Placebet = read('classpath:requests.json')
    * def bet = Placebet.doubleBetSlip

    # Set user informations in bet slip
    * set bet $.[0].accountId = accountId
    * set bet $.[0].userId = userId
    * set bet $.[0].currencyId = currencyId
    * set bet $.[0].branchId = branchId

    * set bet $.[1].accountId = accountId
    * set bet $.[1].userId = userId
    * set bet $.[1].currencyId = currencyId
    * set bet $.[1].branchId = branchId

    #Give First Bet items
    * set bet $.[0].items[0].gameId = gameId
    * set bet $.[0].items[0].marketId = marketId
    * set bet $.[0].items[0].oddId = oddId
    * set bet $.[0].items[0].marketTypeId = marketTypeId
    #---------------------------------------------
    #Give Second Bet items
    * set bet $.[0].items[1].gameId = gameId2
    * set bet $.[0].items[1].marketId = marketId2
    * set bet $.[0].items[1].oddId = oddId2
    * set bet $.[0].items[1].marketTypeId = marketTypeId2
    #---------------------------------------------
    #Give Third Bet items
    * set bet $.[0].items[2].gameId = gameId3
    * set bet $.[0].items[2].marketId = marketId3
    * set bet $.[0].items[2].oddId = oddId3
    * set bet $.[0].items[2].marketTypeId = marketTypeId3
    #---------------------------------------------
    #Give Forth Bet items
    * set bet $.[0].items[3].gameId = gameId4
    * set bet $.[0].items[3].marketId = marketId4
    * set bet $.[0].items[3].oddId = oddId4
    * set bet $.[0].items[3].marketTypeId = marketTypeId4
    #---------------------------------------------
    #Give Second Slip First Bet items
    * set bet $.[-1:].items[0].gameId = gameId
    * set bet $.[-1:].items[0].marketId = marketId
    * set bet $.[-1:].items[0].oddId = oddId
    * set bet $.[-1:].items[0].marketTypeId = marketTypeId
    #---------------------------------------------
    #Give Second Slip Second Bet items
    * set bet $.[-1:].items[1].gameId = gameId2
    * set bet $.[-1:].items[1].marketId = marketId2
    * set bet $.[-1:].items[1].oddId = oddId2
    * set bet $.[-1:].items[1].marketTypeId = marketTypeId2
    #---------------------------------------------
    #Give Second Slip Third Bet items
    * set bet $.[-1:].items[2].gameId = gameId3
    * set bet $.[-1:].items[2].marketId = marketId3
    * set bet $.[-1:].items[2].oddId = oddId3
    * set bet $.[-1:].items[2].marketTypeId = marketTypeId3
    #---------------------------------------------
    #Give Second Slip Forth Bet items
    * set bet $.[-1:].items[3].gameId = gameId4
    * set bet $.[-1:].items[3].marketId = marketId4
    * set bet $.[-1:].items[3].oddId = oddId4
    * set bet $.[-1:].items[3].marketTypeId = marketTypeId4
    #---------------------------------------------
    #Place Bet
    * path '/api/data/bet/placebets'
    * header Authorization = 'Bearer ' + token
    * header Session = session
    * request bet
    * method Post
    * status 200
    * match $.results[:1].placeResultType == [1]
    * def BetID = $.results[-1:].betSlipId
    * print BetID
    #Check Bet
    #---------------------------------------------
    * path '/api/data/userbets/paged'
    * header Authorization = 'Bearer ' + token
    * header Session = session
    # startIndex Of Users Bet History
    * path startIndex = '/250'
    # pageSize Of Users Bet History
    * path pageSize = '/190'
    * method Get
    * status 200
    * def lastBet = $.items[-1:].id
    * print lastBet
    * match lastBet == BetID

  @PlaceDifferentBetsInDifferentSlipTSB
  Scenario: Place Different Bet More Than One Slip
    # Find first betslip items
    * path '/api/data/games/gamesbyleague'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path leagueId = '54'
    * path langId = '1'
    * method Get
    * status 200
    * def firstSlipBets = response
    * print firstSlipBets

    #First Bet First Slip
    #---------------------------------------------
    * def gameId0 = firstSlipBets.items[0].markets[0].gameId
    * print gameId0
    * def marketId0 = firstSlipBets.items[0].markets[0].odds[0].marketId
    * print marketId0
    * def oddId0 = firstSlipBets.items[0].markets[0].odds[0].id
    * print oddId0
    * def marketTypeId0 = firstSlipBets.items[0].markets[0].marketTypeId
    * print marketTypeId0
    * def oddvalue0 = firstSlipBets.items[0].markets[0].odds[0].value
    * print oddvalue0
    #Second Bet First Slip
    #---------------------------------------------
    * def gameId1 = firstSlipBets.items[1].markets[0].gameId
    * print gameId1
    * def marketId1 = firstSlipBets.items[1].markets[0].odds[0].marketId
    * print marketId1
    * def oddId1 = firstSlipBets.items[1].markets[0].odds[0].id
    * print oddId1
    * def marketTypeId1 = firstSlipBets.items[1].markets[0].marketTypeId
    * print marketTypeId1
    * def oddvalue1 = firstSlipBets.items[1].markets[0].odds[0].value
    * print oddvalue1
    #Third Bet First Slip
    #---------------------------------------------
    * def gameId2 = firstSlipBets.items[2].markets[0].gameId
    * print gameId2
    * def marketId2 = firstSlipBets.items[2].markets[0].odds[0].marketId
    * print marketId2
    * def oddId2 = firstSlipBets.items[2].markets[0].odds[0].id
    * print oddId2
    * def marketTypeId2 = firstSlipBets.items[2].markets[0].marketTypeId
    * print marketTypeId2
    * def oddvalue2 = firstSlipBets.items[2].markets[0].odds[0].value
    * print oddvalue2
    #Fourth Bet First Slip
    #---------------------------------------------
    * def gameId3 = firstSlipBets.items[3].markets[1].gameId
    * print gameId3
    * def marketId3 = firstSlipBets.items[3].markets[1].odds[0].marketId
    * print marketId3
    * def oddId3 = firstSlipBets.items[3].markets[1].odds[0].id
    * print oddId3
    * def marketTypeId3 = firstSlipBets.items[3].markets[1].marketTypeId
    * print marketTypeId3
    * def oddvalue3 = firstSlipBets.items[3].markets[0].odds[0].value
    * print oddvalue3

    # Second Betslip İtems
    * path '/api/data/games/gamesbyleague'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path leagueId = '178'
    * path langId = '1'
    * method Get
    * status 200
    * def secondslipbets = response
    * print secondslipbets
    #First Bet of Second Slip
    #---------------------------------------------
    * def gameId4 = secondslipbets.items[0].markets[0].gameId
    * print gameId4
    * def marketId4 = secondslipbets.items[0].markets[0].odds[0].marketId
    * print marketId4
    * def oddId4 = secondslipbets.items[0].markets[0].odds[0].id
    * print oddId4
    * def marketTypeId4 = secondslipbets.items[0].markets[0].marketTypeId
    * print marketTypeId4
    * def oddvalue4 = secondslipbets.items[0].markets[0].odds[0].value
    * print oddvalue4
    #Second Bet of Second Slip
    #---------------------------------------------
    * def gameId5 = secondslipbets.items[1].markets[0].gameId
    * print gameId5
    * def marketId5 = secondslipbets.items[1].markets[0].odds[0].marketId
    * print marketId5
    * def oddId5 = secondslipbets.items[1].markets[0].odds[0].id
    * print oddId5
    * def marketTypeId5 = secondslipbets.items[1].markets[0].marketTypeId
    * print marketTypeId5
    * def oddvalue5 = secondslipbets.items[1].markets[0].odds[0].value
    * print oddvalue5
    #Third Bet of Second Slip
    #---------------------------------------------
    * def gameId6 = secondslipbets.items[2].markets[0].gameId
    * print gameId6
    * def marketId6 = secondslipbets.items[2].markets[0].odds[0].marketId
    * print marketId6
    * def oddId6 = secondslipbets.items[2].markets[0].odds[0].id
    * print oddId6
    * def marketTypeId6 = secondslipbets.items[2].markets[0].marketTypeId
    * print marketTypeId6
    * def oddvalue6 = secondslipbets.items[2].markets[0].odds[0].value
    * print oddvalue6
    #Fourth Bet of Second Slip
    #---------------------------------------------
    * def gameId7 = secondslipbets.items[3].markets[1].gameId
    * print gameId7
    * def marketId7 = secondslipbets.items[3].markets[1].odds[0].marketId
    * print marketId7
    * def oddId7 = secondslipbets.items[3].markets[1].odds[0].id
    * print oddId7
    * def marketTypeId7 = secondslipbets.items[3].markets[1].marketTypeId
    * print marketTypeId7
    * def oddvalue7 = secondslipbets.items[3].markets[0].odds[0].value
    * print oddvalue7

    #Bet Slip
    #---------------------------------------------
    * def Placebet = read('classpath:requests.json')
    * def bet = Placebet.doubleBetSlip

    # Set user informations in bet slip
    * set bet $.[0].accountId = accountId
    * set bet $.[0].userId = userId
    * set bet $.[0].currencyId = currencyId
    * set bet $.[0].branchId = branchId

    * set bet $.[1].accountId = accountId
    * set bet $.[1].userId = userId
    * set bet $.[1].currencyId = currencyId
    * set bet $.[1].branchId = branchId

    #Give First Bet items
    * set bet $.[0].items[0].gameId = gameId0
    * set bet $.[0].items[0].marketId = marketId0
    * set bet $.[0].items[0].oddId = oddId0
    * set bet $.[0].items[0].marketTypeId = marketTypeId0
    #---------------------------------------------
    #Give Second Bet items
    * set bet $.[0].items[1].gameId = gameId1
    * set bet $.[0].items[1].marketId = marketId1
    * set bet $.[0].items[1].oddId = oddId1
    * set bet $.[0].items[1].marketTypeId = marketTypeId1
    #---------------------------------------------
    #Give Third Bet items
    * set bet $.[0].items[2].gameId = gameId2
    * set bet $.[0].items[2].marketId = marketId2
    * set bet $.[0].items[2].oddId = oddId2
    * set bet $.[0].items[2].marketTypeId = marketTypeId2
    #---------------------------------------------
    #Give Forth Bet items
    * set bet $.[0].items[3].gameId = gameId3
    * set bet $.[0].items[3].marketId = marketId3
    * set bet $.[0].items[3].oddId = oddId3
    * set bet $.[0].items[3].marketTypeId = marketTypeId3

    #---------------------------------------------
    #Give Second Slip First Bet items
    * set bet $.[-1:].items[0].gameId = gameId4
    * set bet $.[-1:].items[0].marketId = marketId4
    * set bet $.[-1:].items[0].oddId = oddId4
    * set bet $.[-1:].items[0].marketTypeId = marketTypeId4

    #---------------------------------------------
    #Give Second Slip Second Bet items
    * set bet $.[-1:].items[1].gameId = gameId5
    * set bet $.[-1:].items[1].marketId = marketId5
    * set bet $.[-1:].items[1].oddId = oddId5
    * set bet $.[-1:].items[1].marketTypeId = marketTypeId5

    #---------------------------------------------
    #Give Second Slip Third Bet items
    * set bet $.[-1:].items[2].gameId = gameId6
    * set bet $.[-1:].items[2].marketId = marketId6
    * set bet $.[-1:].items[2].oddId = oddId6
    * set bet $.[-1:].items[2].marketTypeId = marketTypeId6

    #---------------------------------------------
    #Give Second Slip Forth Bet items
    * set bet $.[-1:].items[3].gameId = gameId7
    * set bet $.[-1:].items[3].marketId = marketId7
    * set bet $.[-1:].items[3].oddId = oddId7
    * set bet $.[-1:].items[3].marketTypeId = marketTypeId7

    #---------------------------------------------
    #Place Bet
    * path '/api/data/bet/placebets'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * request bet
    * method Post
    * status 200
    * match $.results[:1].placeResultType == [1]
    * def BetID = $.results[-1:].betSlipId
    * print BetID

    #Check Bet
    #---------------------------------------------
    * path '/api/data/userbets/paged'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    # startIndex Users Bet History
    * path startIndex = '/250'
    # pageSize of User Bet History
    * path pageSize = '/190'
    * method Get
    * status 200
    * def lastBet = $.items[-1:].id
    * print lastBet
    * match lastBet == BetID

  @UserDocumentsTSB
  Scenario: User Documents
    #/api/data/userdocuments/types
    * path '/api/data/userdocuments/types'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    #/api/data/userdocuments/paged/{offset}/{pageSize}
    * path '/api/data/userdocuments/paged'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path offset = '1'
    * path pageSize = '1'
    * method Get
    * status 200

    #/api/data/userdocuments/upload
    * path '/api/data/userdocuments/upload'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And multipart file myFile = { read: 'test.jpg', filename: 'test.jpg', contentType: 'image/jpg' }
    And multipart field message = 'image test'
    # * def ID = call ('classpath:examples/users/test.jpg')
    # * request 'ID'
    * param filename = 'test.jpg'
    * param documentType = '1'
    * method Post
    * status 200

  @UserBetsTSB
  Scenario: UserBets
    #/api/data/userbets/paged/{startIndex}/{pageSize}
    * path '/api/data/userbets/paged'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path startIndex = '1'
    * path pageSize = '100'
    * method Get
    * status 200

    #/api/data/userbets/{betSlipId}/{languageId}
    * path '/api/data/userbets'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path betSlipId = '32920'
    * path languageId = '1'
    * method Get
    * status 200

    #/api/data/userbets/topwinners/{pageSize}/{offset}
    * path '/api/data/userbets/topwinners'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path pageSize = '1000'
    * path offset = '1'
    * method Get
    * status 200

  @UserAccountTSB
  Scenario: UserAccount
    #/api/data/useraccount/{userId}
    * path '/api/data/useraccount'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path userId = '23547'
    * method Get
    * status 200

    #/api/data/useraccount/{userId}/{currencyId}
    * path '/api/data/useraccount'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path userId = '23547'
    * path currencyId = '38'
    * method Get
    * status 200

    #/api/data/useraccount/{accountId}/accountings/{startIndex}/{pageSize}/{langId}
    * path '/api/data/useraccount'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path accountId = '46655'
    * path accountings = 'accountings'
    * path startIndex = '1'
    * path pageSize = '100'
    * path currencyId = '1'
    * method Get
    * status 200

  @SecurityQuestionsTSB
  Scenario: Security Questions
    # /api/data/securityquestions
    * path '/api/data/securityquestions'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    # /api/data/securityquestions/ids
    * path '/api/data/securityquestions/ids'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    # /api/data/securityquestions
    * path '/api/data/securityquestions'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path id = '2'
    * method Get
    * status 200

  @SportsLeagueBrowserTSB
  Scenario: SportsLeaugeBrowser
    #/api/data/slb/sports/{sportid}/{langId}
    * path '/api/data/slb/sports'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path sportid = '1'
    * path LangId = '/1'
    * method Get
    * status 200

    #/api/data/slb/sports/{startDate}/{endDate}/{state}/{langId}
    * path '/api/data/slb/sports'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path starDate = '/2018-05-23T11:57:17'
    * path endDate = '/2023-05-23T11:57:17'
    * path state = '2'
    * path LangId = '/1'
    * method Get
    * status 200

    #/api/data/slb/sports/{sportId}/categories/{startDate}/{endDate}/{state}/{langId}
    * path '/api/data/slb/sports'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path sportId = '1'
    * path categories = 'categories'
    * path starDate = '2018-05-23T11:57:17'
    * path endDate = '2023-05-23T11:57:17'
    * path state = '2'
    * path langId = '1'
    * method Get
    * status 200

    #/api/data/slb/sports/{sportId}/categories/{categoryId}/{startDate}/{endDate}/{state}/{langId}
    * path '/api/data/slb/sports'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path sportId = '1'
    * path categories = 'categories'
    * path categoryId = '1'
    * path starDate = '2018-05-23T11:57:17'
    * path endDate = '2023-05-23T11:57:17'
    * path state = '2'
    * path langId = '1'
    * method Get
    * status 200

    #/api/data/slb/sports/{sportId}/categories/{categoryId}/leagues/{startDate}/{endDate}/{state}/{langId}
    * path '/api/data/slb/sports'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path sportId = '1'
    * path categories = 'categories'
    * path categoryId = '1'
    * path leagues = 'leagues'
    * path starDate = '2018-05-23T11:57:17'
    * path endDate = '2023-05-23T11:57:17'
    * path state = '2'
    * path langId = '1'
    * method Get
    * status 200

  #/api/data/slb/sports/{sportId}/categories/{categoryId}/leagues/{leagueId}/{startDate}/{endDate}/{state}/{langId}
    * path '/api/data/slb/sports'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path sportId = '1'
    * path categories = 'categories'
    * path categoryId = '1'
    * path leagues = 'leagues'
    * path leagueId = ''
    * path starDate = '2018-05-23T11:57:17'
    * path endDate = '2023-05-23T11:57:17'
    * path state = '2'
    * path langId = '1'
    * method Get
    * status 200

  @SportsTSB
  Scenario: Sports
    * path '/api/data/sports'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    * path '/api/data/sports'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path id = '3'
    * method Get
    * status 200

    * path '/api/data/sports/ids'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    * path '/api/data/sports/bettable'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path starDate = '/2018-05-23T11:57:17'
    * path endDate = '/2023-05-23T11:57:17'
    * path LangId = '/1'
    * method Get
    * status 200

#    * path '/api/data/sports/evaluated'
#    And header Authorization = 'Bearer ' + token
#    And header Session = session
#    * path starDate = '/2018-05-23T11:57:17'
#    * path endDate = '/2023-05-23T11:57:17'
#    * path LangId = '/1'
#    * method Get
#    * status 200

    * path '/api/data/sports/all'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path starDate = '/2018-05-23T11:57:17'
    * path endDate = '/2023-05-23T11:57:17'
    * path LangId = '/1'
    * method Get
    * status 200

  @CountriesTSB
  Scenario: Countries
    #/api/data/countries
    * path '/api/data/countries'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    #/api/data/countries/ids
    * path '/api/data/countries/ids'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param ids = '2'
    * method Get
    * status 200

    #/api/data/countries/{ids}
    * path '/api/data/countries'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path id = '2'
    * method Get
    * status 200

  @CurrencyTSB
  Scenario: Available currencies
    #/api/data/currencies
    * path '/api/data/currencies'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    #/api/data/currencies/ids
    * path '/api/data/currencies/ids'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param ids = '2'
    * method Get
    * status 200

    #/api/data/currencies/{ids}
    * path '/api/data/currencies'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path id = '2'
    * method Get
    * status 200

  @CashTypeTSB
  Scenario: Available CashType
    #/api/data/account/cashtypes
    * path '/api/data/account/cashtypes'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    #/api/data/account/cashtypes/ids
    * path '/api/data/account/cashtypes/ids'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param ids = '23'
    * method Get
    * status 200

    #/api/data/account/cashtypes/{ids}
    * path '/api/data/account/cashtypes'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path id = '23'
    * method Get
    * status 200

  @MarketTypeTSB
  Scenario: Available MarketType
    #/api/data/markettypes
    * path '/api/data/markettypes'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    #/api/data/markettypes/ids
    * path '/api/data/markettypes/ids'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param ids = '23'
    * method Get
    * status 200

    #/api/data/markettypes/{ids}
    * path '/api/data/markettypes'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path id = '23'
    * method Get
    * status 200

  @MarketTypeCategoryTSB
  Scenario: Available MarketTypeCategory
    #/api/data/markettype/categories
    * path '/api/data/markettype/categories'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    #/api/data/markettype/categories/ids
    * path '/api/data/markettype/categories/ids'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param ids = '2'
    * method Get
    * status 200

    #/api/data/markettype/categories/{ids}
    * path '/api/data/markettype/categories'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path id = '2'
    * method Get
    * status 200

  @TimeZoneTSB
  Scenario: Available TimeZone
    #/api/data/timezone
    * path '/api/data/timezone'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    #/api/data/timezone/ids
    * path '/api/data/timezone/ids'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param ids = '2'
    * method Get
    * status 200

    #/api/data/timezone/{ids}
    * path '/api/data/timezone'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path id = '2'
    * method Get
    * status 200

  @GamesTSB
 Scenario:List the available games with filters
    * def availablegames = call read('ServiceTestsTSB.feature@ListofGames')
    * def response = availablegames.response
    
    #Defination of some params from all available games method
    * def gameId = $.items[0].markets[0].gameId
    * print ('gameId: ' + gameId)
    * def marketId = $.items[0].markets[0].odds[0].marketId
    * print 'marketId: ', marketId
    * def leagueId = $.items[0].leagueId
    * print 'leagueId: ', leagueId

    #List of available games for specified id based on language id
    And path '/api/data/games'
    And path id = gameId
    And path langId = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #List of specified games with extra info
    And path '/api/data/games/'
    And path id = gameId
    And path '/extrainfo'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #List of specified games with filtered market ıd
    And path '/api/data/games/'
    And path id = gameId
    And path langId = '1'
    And path '/market'
    And path marketId = marketId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #List of games filtered by league id based on the language
    And path '/api/data/games/gamesbyleague/'
    And path leagueId = leagueId
    And path langId = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #List of games filtered by league id based on the language
    And path '/api/data/games/all/'
    And path leagueId = leagueId
    And path langId = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #List of games filtered by start and end dates
    And path '/api/data/games/'
    And path startDate = '2018-05-23'
    And path endDate = '2023-05-23'
    And path langId = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Games List with id and langId, and a specified marketId
    #/api/data/games/{id}/{langId}/market/{marketId}
    And path '/api/data/games'
    * path id = gameId
    * path langId = '1'
    * path market = 'market'
    * path marketId = marketId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

  @GamePeriodsTSB
  Scenario: Game Periods
  
    #list of all Game Periods
    And path '/api/data/gameperiods'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def id = $.[0].id
    * print 'id: ', id

    #Game Periods filtered by specific id
    And path '/api/data/gameperiods/ids'
    And param ids = id
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Game Periods filtered by specific id
    And path '/api/data/gameperiods/'
    And path id = id
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

  @AllLeaguesTSB
  Scenario: List of all leagues

    #List of all leagues
    And path '/api/data/leagues/ids'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

  @LeaguesTSB
  Scenario: Leagues Service test from AllLeaguesTSB scenario
    #Definition of some parameters used for leagues from ServiceTestsTSB.feature@AllLeaguesTSB
    * def x = call read('ServiceTestsTSB.feature@AllLeaguesTSB')
    * def response = x.response
    * def leagueId = $.[1].masterId
    * print 'leagueId: ', leagueId
    * def sportId = $.[1].sportId
    * print 'sportId: ',sportId
    * def categoryId = $.[1].gameCategoryId
    * print 'categoryId: ',categoryId
    * def startDate = '2019-03-11'
    * print 'startDate: ',startDate
    * def endDate = '2023-03-11'
    * print 'endDate: ',endDate

    #List of games filtered by league id
    #/api/data/leagues/ids
    And path '/api/data/leagues/ids'
    And param ids = leagueId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #List of games filtered by league id
    #/api/data/leagues/{leagueId}
    And path '/api/data/leagues/'
    And path leagueId = leagueId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Bettable Leagues
    #/api/data/leagues/bettable/{sportId}/{categoryId}/{startDate}/{endDate}/{langId}
    And path '/api/data/leagues/bettable'
    And path sportId = sportId
    And path categoryId = categoryId
    And path startDate = startDate
    And path endDate = endDate
    And path langId = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #All Available Leagues with filters
    #/api/data/leagues/all/{sportId}/{categoryId}/{startDate}/{endDate}/{langId}
    And path '/api/data/leagues/all'
    And path sportId = sportId
    And path categoryId = categoryId
    And path startDate = startDate
    And path endDate = endDate
    And path langId = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #List of available leagues filtered by languageId based on sportId
    #/api/data/leagues/search/{languageId}/
    And path '/api/data/leagues/search'
    And path languageId = '1'
    * param sportId = sportId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

  @LeagueSeasonsTSB
  Scenario: LeagueSeasons

    #list of all League Seasons
    And path '/api/data/leagueseasons'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def leagueseasonsId = $.[0].id
    * print 'leagueseasonsId: ', leagueseasonsId

    #League Season filtered by specific id
    And path '/api/data/leagueseasons/ids'
    And param ids = leagueseasonsId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #League Season filtered by specific id
    And path '/api/data/leagueseasons/'
    And path leagueId = leagueseasonsId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

  @LanguagesTSB
  Scenario: Languages
    #List of All Languages
    And path '/api/data/languages'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def languageId = $.[0].id
    * print 'languageId: ',languageId

    #Language filtered by specific language id
    And path '/api/data/languages/ids'
    * param ids = languageId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Language filtered by specific language id
    #/api/data/languages/{id}
    And path '/api/data/languages/'
    * path id = languageId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

  @CategoriesTSB
  Scenario: Category
    #Defination of some parameters used for leagues from ServiceTestsTSB.feature@AllLeaguesTSB
    * def x = call read('ServiceTestsTSB.feature@AllLeaguesTSB')
    * def response = x.response
    * def sportId = $.[1].sportId
    * print 'sportId: ',sportId
    * def startDate = '2019-03-11'
    * print 'startDate: ',startDate
    * def endDate = '2023-03-11'
    * print 'endDate: ',endDate

    And path '/api/data/categories'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def ids = $.[0].id
    * print 'ids: ',ids

    #List of games filtered by categories id
    And path '/api/data/categories/ids'
    And param ids = ids
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #List of games filtered by categories id
    And path '/api/data/categories/'
    And path ids = ids
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Bettable Categories
    And path '/api/data/categories/bettable'
    And path sportId = sportId
    And path startDate = startDate
    And path endDate = endDate
    And path langId = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #All Categories with filters
    #/api/data/categories/all/{sportId}/{categoryId}/{startDate}/{endDate}/{langId}
    And path '/api/data/categories/all'
    And path sportId = sportId
    And path startDate = startDate
    And path endDate = endDate
    And path langId = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #List of Leagues filtered by languageId based on sportId
    #/api/data/leagues/search/{languageId}/
    And path '/api/data/leagues/search'
    And path languageId = '1'
    * param sportId = sportId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

  @UserTSB
  Scenario: User externalratings
    #/api/data/user/{userId}/externalrating
    * path '/api/data/user'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path userId = '23547'
    * path 'externalrating'
    * method Get
    * status 204

    * path '/api/data/user'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param identity = '23547'
    * param identityType = 5
    * method Get
    * status 200

    * path '/api/data/user/profile'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

    * path '/api/data/user/tags'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

      #/api/data/user/ratings
    * path '/api/data/user/ratings'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

  @UserSecurityQuestionChange
  Scenario: Change Security Questions
    * path '/api/data/user/securityquestion'
    And header Authorization = 'Bearer ' + token
    And header Session = session

    * def securityQuestion =
    """
    {
    "oldQuestionId": 1,
    "oldAnswer": "7",
    "newQuestionId": 2,
    "newAnswer": "12"
    }
    """
    * request securityQuestion
    * method Post
    * status 200

    * path '/api/data/user/securityquestion'
    And header Authorization = 'Bearer ' + token
    And header Session = session

    * def securityQuestions =
    """
    {
  "oldQuestionId": 2,
  "oldAnswer": "12",
  "newQuestionId": 1,
  "newAnswer": "7"
}
    """
    * request securityQuestions
    * method Post
    * status 200

  @KYC
  Scenario: levels
    #/api/data/kyc/levels/{branchId}
    * path '/api/data/kyc/levels'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path branchId = '32'
    * method Get
    * status 200

    #KYC bet
    #/api/data/kyc/bet/actions/{branchId}
    * path '/api/data/kyc/bet/actions'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path branchId = '32'
    * method Get
    * status 200

    #KYC Marketing
    #/api/data/kyc/marketing/actions/{branchId}
    * path '/api/data/kyc/marketing/actions'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path branchId = '32'
    * method Get
    * status 200

    #KYC messaging
    #/api/data/kyc/messaging/actions/{branchId}
    * path '/api/data/kyc/messaging/actions'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path branchId = '32'
    * method Get
    * status 200

    #KYC payment
    #/api/data/kyc/payment/actions/{branchId}
    * path '/api/data/kyc/payment/actions'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path branchId = '32'
    * method Get
    * status 200

    #KYC rating
    #/api/data/kyc/rating/actions/{branchId}
    * path '/api/data/kyc/rating/actions'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path branchId = '32'
    * method Get
    * status 200

    #KYC user
    #/api/data/kyc/user/actions/{branchId}
    * path '/api/data/kyc/user/actions'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path branchId = '32'
    * method Get
    * status 204

  @BonusList
  Scenario: Bonus list
    #/api/data/bonus
    * path '/api/data/bonus'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200

   #Bonus list Paged
    #/api/data/bonus
    * path '/api/data/bonus'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param startIndex = '5'
    * param pageSize = '5'
    * method Get
    * status 200

  @ResendE-mailVerification
  Scenario: Resend E-mail
    Given path '/api/data/user/signout'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * request ''
    * method Post
    * status 200

    * def Session =
    """
  {
  "deviceIdentifier": "Testinium-QA",
  "userAgent": "testinium",
  "ipAddress": "54.154.66.64",
  "appId": "B3FC4148-E184-450B-95EE-25D7CDE63218"
  }
    """
    * path '/api/session/create'
    * header Authorization = 'Bearer ' + token
    * request Session
    * method Post
    * status 200
    * def anonSession = $.sessionToken
    * print anonSession
    And header Session = anonSession

    * path '/api/data/user/resendemailverification/byemail'
    And header Authorization = 'Bearer ' + token
    And header Session = anonSession
    * path email = 'testdenemet.r.est.iniumm@gmail.com'
    * request ' '
    * method POST
    * status 200
    * match response == 'testdenemet.r.est.iniumm@gmail.com'

    * path '/api/data/user/resendemailverification/byusername'
    And header Authorization = 'Bearer ' + token
    And header Session = anonSession
    * path userName = 'denemeeme'
    * request ' '
    * method POST
    * status 200
    * match response == 'testdenemet.r.est.iniumm@gmail.com'

    * path '/api/data/user/resendemailverification/byid'
    And header Authorization = 'Bearer ' + token
    And header Session = anonSession
    * path userId = '23812'
    * request ' '
    * method POST
    * status 200
    * match response == 'testdenemet.r.est.iniumm@gmail.com'

  @TransactionsTSB
  Scenario: Transactions
    #Get a list of the payment handlers
    And path '/api/data/payment/gethandlers'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * match $[0].name == '#notnull '
    * def handlerIdForDeposit = $[0].id
    * print 'handlerIdForDeposit: ', handlerIdForDeposit
    * def handlerIdForWithdrawal = $[1].id
    * print 'handlerIdForWithdrawal: ', handlerIdForWithdrawal
    * def providerId = $[0].paymentProvider.id
    * print 'providerId: ', providerId

    #To initialize the payment transaction for withdrawal
    And path '/api/data/payment/init'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request ''
    * path accountId = accountId
    * path handlerId = handlerIdForWithdrawal
    When method Post
    Then status 200
    * def transactionIdForWthdrwl = $.transaction.id
    * print 'transactionIdForWthdrwl: ', transactionIdForWthdrwl

    #Prepared the transaction operation
    And path '/api/data/payment/operation'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * def operationTransaction = req.operationTransactionWithdrawal
    And request operationTransaction
    * path paymentTransactionId = transactionIdForWthdrwl
    * path type = 2
    When method Post
    Then status 200
    * match $.messageCode == 0
    * match $.message == null
    * match $.transaction.state == 7

    #Pending the last transaction operation
    And path '/api/data/payment/operation'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * def operationTransaction = req.operationTransactionWithdrawal
    And request operationTransaction
    * path paymentTransactionId = transactionIdForWthdrwl
    * path type = 4
    When method Post
    Then status 200
    * match $.messageCode == 0
    * match $.message == null
    * match $.transaction.state == 2

    #Requesting the last transaction operation
    And path '/api/data/payment/operation'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * def operationTransaction = req.operationTransactionWithdrawal
    And request operationTransaction
    * path paymentTransactionId = transactionIdForWthdrwl
    * path type = 3
    When method Post
    Then status 200
    * match $.messageCode == 0
    * match $.message == null
    * match $.transaction.state == 10

    #To initialize the payment transaction for deposit
    And path '/api/data/payment/init'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And request ''
    * path accountId = accountId
    * path handlerId = handlerIdForDeposit
    When method Post
    Then status 200
    * def transactionId = $.transaction.id
    * print 'transactionId: ', transactionId

    #Prepared the transaction operation
    And path '/api/data/payment/operation'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * def operationTransaction = req.operationTransactionDeposit
    And request operationTransaction
    * path paymentTransactionId = transactionId
    * path type = 2
    When method Post
    Then status 200
    * match $.messageCode == 0
    * match $.message == null
    * match $.transaction.state == 7

    #Pending the last transaction operation
    And path '/api/data/payment/operation'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * def operationTransaction = req.operationTransactionDeposit
    And request operationTransaction
    * path paymentTransactionId = transactionId
    * path type = 4
    When method Post
    Then status 200
    * match $.messageCode == 0
    * match $.message == null
    * match $.transaction.state == 2
    * def RedirectUri = $.transaction.requestParameters.RedirectUri
    * print 'RedirectUri: ', RedirectUri

    #Get payment transaction for a specified transactionId
    And path '/api/data/payment'
    * path transactionId = transactionId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def fingerPrint = $.fingerPrint
    * print 'fingerPrint: ', fingerPrint

    #Get payment transaction for a specified fingerprint
    And path '/api/data/payment/byfingerprint'
    * path fingerPrint = fingerPrint
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Get payment provider for a specified provided
    And path '/api/data/payment/identities'
    * path providerId = providerId
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Get defined card for  a specified user
    And path '/api/data/payment/identities/cards'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def cardname = $[0].name
    * print 'cardname: ', cardname
    * match cardname == '400000******0077'

  @PaymentSelflimits
  Scenario: Payment Limits
   #To retrieve the payment settings
   And path '/api/data/payment/settings'
  And header Authorization = 'Bearer ' + token
   And header Session = session
   When method Get
   Then status 200
 
 #    #Defined as one value less than the existing paymentLimit's value for admin user
 #    * def maxDepositPerDay = $.maxDepositPerD
 #    * print 'maxDepositPerDay: ', maxDepositPerDay
 #    * def newMaxDepositPerDay = maxDepositPerDay - 1
 #    * print 'newMaxDepositPerDay: ', newMaxDepositPerDay
 #
 #    * def maxDepositPerWeek = $.maxDepositPerW
 #    * print 'maxDepositPerWeek: ', maxDepositPerWeek
 #    * def newMaxDepositPerWeek = maxDepositPerWeek - 1
 #    * print 'newMaxDepositPerWeek: ', newMaxDepositPerWeek
 #
 #    * def maxDepositPerMonth = $.maxDepositPerM
 #    * print 'maxDepositPerMonth: ', maxDepositPerMonth
 #    * def newMaxDepositPerMonth = maxDepositPerMonth - 1
 #    * print 'newMaxDepositPerMonth: ', newMaxDepositPerMonth

   #Defined as one value less than the existing paymentLimit's value for customer
   * def custMaxDepositPerDay = $.custMaxDepositPerD
   * print 'custMaxDepositPerDay: ', custMaxDepositPerDay
   * def newCustMaxDepositPerDay = custMaxDepositPerDay - 1
   * print 'newCustMaxDepositPerDay: ', newCustMaxDepositPerDay

   * def custMaxDepositPerWeek = $.custMaxDepositPerW
   * print 'custMaxDepositPerWeek: ', custMaxDepositPerWeek
   * def newCustMaxDepositPerWeek = custMaxDepositPerWeek - 1
   * print 'newCustMaxDepositPerWeek: ', newCustMaxDepositPerWeek

   * def custMaxDepositPerMonth = $.custMaxDepositPerM
   * print 'custMaxDepositPerMonth: ', custMaxDepositPerMonth
   * def newCustMaxDepositPerMonth = custMaxDepositPerMonth - 1
   * print 'newCustMaxDepositPerMonth: ', newCustMaxDepositPerMonth

   #To check to set the deposit limit
   And path '/api/data/payment/timelimit/check'
   And header Authorization = 'Bearer ' + token
   And header Session = session
   * def paymentLimit = req.paymentLimit
 # * set paymentLimit $.maxDepositPerD = newMaxDepositPerDay
 # * set paymentLimit $.maxDepositPerW = newMaxDepositPerWeek
 # * set paymentLimit $.maxDepositPerM = newMaxDepositPerMonth
   * set paymentLimit $.custMaxDepositPerD = newCustMaxDepositPerDay
   * set paymentLimit $.custMaxDepositPerW = newCustMaxDepositPerWeek
   * set paymentLimit $.custMaxDepositPerM = newCustMaxDepositPerMonth
   And request paymentLimit
   When method Post
   Then status 200
   * match $.ok == true

   #Save the defined values from "selflimitcheck" request
   And path '/api/data/payment/timelimit'
   And header Authorization = 'Bearer ' + token
   And header Session = session
   * def paymentLimitsave = req.paymentLimit
 #  * set paymentLimitsave $.maxDepositPerD = newMaxDepositPerDay
 #  * set paymentLimitsave $.maxDepositPerW = newMaxDepositPerWeek
 #  * set paymentLimitsave $.maxDepositPerM = newMaxDepositPerMonth
   * set paymentLimitsave $.custMaxDepositPerD = newCustMaxDepositPerDay
   * set paymentLimitsave $.custMaxDepositPerW = newCustMaxDepositPerWeek
   * set paymentLimitsave $.custMaxDepositPerM = newCustMaxDepositPerMonth
   * request paymentLimitsave
   When method Post
   Then status 200
   * match $.ok == true

   #To retrieve the payment settings
   And path '/api/data/payment/settings'
   And header Authorization = 'Bearer ' + token
   And header Session = session
   When method Get
   Then status 200

   #Get self limit settings values and the settled values
 #  * match newMaxDepositPerDay == $.maxDepositPerD
 #  * match newMaxDepositPerWeek == $.maxDepositPerW
 #  * match newMaxDepositPerMonth == $.maxDepositPerM
   * match newCustMaxDepositPerDay == $.custMaxDepositPerD
   * match newCustMaxDepositPerWeek == $.custMaxDepositPerW
   * match newCustMaxDepositPerMonth == $.custMaxDepositPerM

  @UserRegisterTSB
  Scenario: Register
    Given path '/api/data/user/register'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * def random_string =
 """
 function(s) {
   var text = "";
   var possible = "abcdefghijklmnopqrstuvwxyz123456789";
   for (var i = 0; i < s; i++)
     text += possible.charAt(Math.floor(Math.random() * possible.length));
   return text;
 }
 """
    * def random_name =
 """
 function(s) {
   var text = "";
   var possible = "abcdefghijklmnopqrstuvwxyz";
   for (var i = 0; i < s; i++)
     text += possible.charAt(Math.floor(Math.random() * possible.length));
   return text;
 }
 """
    * def random_number =
 """
 function(s) {
   var text = "";
   var possible = "123456789";
   for (var i = 0; i < s; i++)
     text += possible.charAt(Math.floor(Math.random() * possible.length));
   return text;
 }
 """
    * def email =  random_string(5) + '@gmailtest.com'
    * print 'mail:', email

    * def username =  random_string(8)
    * print 'username:', username

    * def name = random_name(5)
    * print 'name: ', name

    * def lastname = random_name(5)
    * print 'lastname: ', lastname

    * def password = random_string(8)
    * print 'Password: ', password

    * def NId = random_number(12)
    * print 'NationalId: ', NId

    * def phoneNumber = random_number(10)
    * print 'phone number: ', phoneNumber

    * def RFID = random_number(4)
    * print 'RFID: ', RFID

    * def Register = read('classpath:requests.json')
    * def Registeration = Register.Register

    * set Registeration $.eMail.name = email
    * set Registeration $.password = password
    * set Registeration $.profile.firstName = name
    * set Registeration $.profile.lastName = lastname
    * set Registeration $.profile.nationalIdentityId = NId
    * set Registeration $.profile.phoneNumbers[0].name = phoneNumber
    #* set Registeration $.rfidNumber = RFID
    * set Registeration $.logonName = username
    * set Registeration $.branchId = branchId
    * set Registeration $.currencyId = currencyId
    * request Registeration
    * method Post
    * status 200

  @SessionTSB
  Scenario: checksession
    #/api/session/checksession
    * path '/api/session/checksession'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200
    #Get session of specific user
    #session
    #/api/session
    * path '/api/session'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * method Get
    * status 200
    #Session extend
    #session Touch
    #/api/session
    * path '/api/session/touch'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * request ' '
    * method Post
    * status 200

  @GamingSession
  Scenario: Gaming Session
    #/api/data/gaming/session/{gameId}/{lang}
    Given path '/api/data/gaming/session'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * def random_number =
 """
 function(s) {
   var text = "";
   var possible = "123456789";
   for (var i = 0; i < s; i++)
     text += possible.charAt(Math.floor(Math.random() * possible.length));
   return text;
 }
 """
    * def gameId = random_number(1)
    * print 'gameId: ', gameId

    * path gameId = gameId
    * path lang = '1'
    * method Get
    * status 200

  @Checkbetitem
  Scenario: Check bet item for the first added bet
    * def listofavbets = call read('ServiceTestsTSB.feature@ListofGames')
    * def responsebets = listofavbets.response

    #Defining the first game values in the list of available games
    * def gameId = responsebets.items[0].markets[0].gameId
    And print gameId
    * def marketId = responsebets.items[0].markets[0].odds[0].marketId
    And print marketId
    * def oddId = responsebets.items[0].markets[0].odds[0].id
    And print oddId
    * def marketTypeId = responsebets.items[0].markets[0].marketTypeId
    And print marketTypeId
    * def value = responsebets.items[0].markets[0].odds[0].value
    And print value

    #Defining "checkbetitem" parameter pulled from json file as "checkbetitem"
    * def checkbetitem = req.checkbetitem

    And path '/api/data/bet/checkbetitem'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param GameId = gameId
    * param OddId = oddId
    * param MarketId = marketId
    * param MarketTypeId = marketTypeId
    * param OddValue = value
    * param Settled = false
    And request checkbetitem
    When method Post
    Then status 200
    Then match $.type == 0

  @Checksameaddedbetitem 
  Scenario: Check bet item for the same added bet
    * def listofavbets = call read('ServiceTestsTSB.feature@ListofGames')
    * def responsebets = listofavbets.response

    #Defining the first game values in the list of available games
    * def gameId = responsebets.items[0].markets[0].gameId
    And print gameId
    * def marketId = responsebets.items[0].markets[0].odds[0].marketId
    And print marketId
    * def oddId = responsebets.items[0].markets[0].odds[0].id
    And print oddId
    * def marketTypeId = responsebets.items[0].markets[0].marketTypeId
    And print marketTypeId
    * def value = responsebets.items[0].markets[0].odds[0].value
    And print value

    #Defining the same game with the diffirent values in the list of available games
    * def gameId2 = responsebets.items[0].markets[0].gameId
    And print gameId2
    * def marketId2 = responsebets.items[0].markets[0].odds[1].marketId
    And print marketId2
    * def oddId2 = responsebets.items[0].markets[0].odds[1].id
    And print oddId2
    * def marketTypeId2 = responsebets.items[0].markets[0].marketTypeId
    And print marketTypeId2
    * def value2 = responsebets.items[0].markets[0].odds[1].value
    And print value2

    #Defining "checkbetitem" parameter pulled from json file as "checkbetitem"
    * def checkbetitem = req.checkbetitem

    #Set the datas for first game from first defined available game
    And set checkbetitem $.items[0].gameId = gameId2
    And set checkbetitem $.items[0].marketId = marketId2
    And set checkbetitem $.items[0].oddId = oddId2
    And set checkbetitem $.items[0].marketTypeId = marketTypeId2
    And set checkbetitem $.items[0].oddValue = value2

    And path '/api/data/bet/checkbetitem'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param GameId = gameId
    * param OddId = oddId
    * param MarketId = marketId
    * param MarketTypeId = marketTypeId
    * param OddValue = value
    * param Settled = false
    And request checkbetitem
    When method Post
    Then status 200
    Then match $.type == 5
    #This result type's definition is that MultiwaysNotAllowed - new item is a non-allowed multiway

  @Checkbet
  Scenario: Check bet
    * def listofavbets = call read('ServiceTestsTSB.feature@ListofGames')
    * def responsebets = listofavbets.response

    #Defining the first game values in the list of available games
    * def gameId = responsebets.items[0].markets[0].gameId
    And print gameId
    * def marketId = responsebets.items[0].markets[0].odds[0].marketId
    And print marketId
    * def oddId = responsebets.items[0].markets[0].odds[0].id
    And print oddId
    * def marketTypeId = responsebets.items[0].markets[0].marketTypeId
    And print marketTypeId
    * def value = responsebets.items[0].markets[0].odds[0].value
    And print value

    #Defining "checkbet" parameter pulled from json file as "checkbet"
    * def checkbet = req.checkbet

    #Set the individual user information from the response of signin method
    * set checkbet $.branchId = branchId
    * set checkbet $.accountId = accountId
    * set checkbet $.userId = userId
    * set checkbet $.currencyId = currencyId

    #Set the datas for first game from first defined available game
    And set checkbet $.items[0].gameId = gameId
    And set checkbet $.items[0].marketId = marketId
    And set checkbet $.items[0].oddId = oddId
    And set checkbet $.items[0].marketTypeId = marketTypeId
    And set checkbet $.items[0].oddValue = value

    #Check bet request, "options=131071" param is used for test all of thing on the bet
    And path '/api/data/bet/checkbet'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * param options = '131071'
    And request checkbet
    When method Post
    Then status 200
    Then match $.checkResultType == 1
  #    * def expectedres = { errors: '#null' }
  #    * match response contains '#(^expectedres)'
    * match $.errors == []
    * match $.warnings == []  

  #Get the risk rules for betting
    * path '/api/data/bet/risk/settings'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def minStakePerBetSlip = $.minimumStakePerBetSlip

    #this function uses for to take just two decimal from the value as minStake
    * def num =
   """
    function(x) {
     return Number.parseFloat(x).toFixed(2);
    }
   """

    * def minStakeFromFunc = num(minStake)
    * print 'minStakeFromFunc: ', minStakeFromFunc
    
    * def sevenTimesMinStakePerBet = minStakePerBetSlip*7.69
    * print 'sevenTimesMinStakePerBet: ', sevenTimesMinStakePerBet
    * match minStakeFromFunc*1 == sevenTimesMinStakePerBet
  

  @Addtorecent
  Scenario: Add to recent place bet
    #Call the response of List of Games request to define the parameters which will use add to recent request
    * def availablegames = call read('ServiceTestsTSB.feature@ListofGames')
    * def response = availablegames.response

    #Defining the game values in the list of available games
    * def gameId = $.items[0].markets[0].gameId
    And print 'gameId: ', gameId
    * def marketId = $.items[0].markets[0].odds[0].marketId
    And print 'marketId: ', marketId
    * def oddId = $.items[0].markets[0].odds[0].id
    And print 'oddId: ', oddId
    * def marketTypeId = $.items[0].markets[0].marketTypeId
    And print 'marketTypeId: ', marketTypeId
    * def value = $.items[0].markets[0].odds[0].value
    And print 'value: ',value

    #Defining "recentplacebet" parameter pulled from json file as "recentBet"
    * def recentplacebet = req.recentBet
    #--------------------------------------------------
    #Set the individual user information from the response of signin method
    * set recentplacebet $.branchId = branchId
    * set recentplacebet $.accountId = accountId
    * set recentplacebet $.userId = userId
    * set recentplacebet $.currencyId = currencyId
    #--------------------------------------------------
    #The datas which the defined games from list of available games
    And set recentplacebet $.items[0].gameId = gameId
    And set recentplacebet $.items[0].marketId = marketId
    And set recentplacebet $.items[0].oddId = oddId
    And set recentplacebet $.items[0].marketTypeId = marketTypeId
    And set recentplacebet $.items[0].oddValue = value

    #Add to recent place bet method
    And path '/api/data/bet/placebet'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path addToRecent = 'true'
    And request recentplacebet
    When method Post
    Then status 200
    * def expected = { guid: '#notnull' }
    * match response contains '#(^expected)'
    * def xguid = $.guid
    * print 'guid: ', xguid

    * def sleep = function(millis){ java.lang.Thread.sleep(millis) }
    * sleep(1000)

    #Get the recent bet info base on guid
    And path '/api/data/bet/state'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    And path guid = xguid
    When method Get
    Then status 200
    * match response.guid == xguid
    * def expectedresult = { results: '#notnull' }
    * match response contains '#(^expectedresult)'

    * def lastrecentbet = $.results[0].betSlipId
    * print 'lastrecentbet: ', lastrecentbet

    #List of Recent Bet
    And path '/api/data/bet/state/recent'
    And path languageId= 1
    * param limit = 100
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def lastrecentbetinlist = $[-1].result.results[-1].betSlipId
    * print 'lastrecentbetinlist: ', lastrecentbetinlist
    * match lastrecentbetinlist != 0
    * match lastrecentbetinlist == lastrecentbet  

  @Commons
  Scenario: Commons
    #Get the list of all languages
    And path '/api/data/common/languages'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def langId = $[0].id

    #Get the list of the available countries for a given language
    And path '/api/data/common/languages/'
    And path langId = langId
    And path '/countries'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Get the list of the available currencies for a given language
    And path '/api/data/common/languages/'
    And path langId = langId
    And path '/currencies'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Get the list of the available timezones for a given language
    And path '/api/data/common/languages/'
    And path langId = langId
    And path '/timezones'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200  

  Scenario: Ratings
    #Get the list of all rating in admin site
    And path '/api/data/rating/external'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

    #Get the user time limits for defined id= 1
    #This part from [bmnext_ratings].[dbo].[tUserTimedLimitSettings]
    And path '/api/data/rating/timelimits'
    And path id = 1
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * match $.id == 1


  @ResetPassword
  Scenario: ResetPassword
    Given path '/api/data/user/signout'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * request ''
    * method Post
    * status 200
    * def Session =
    """
  {
  "deviceIdentifier": "Testinium-Cloud",
  "userAgent": "testinium",
  "ipAddress": "54.154.66.64",
  "appId": "B3FC4148-E184-450B-95EE-25D7CDE63218"
  }
    """
    * path '/api/session/create'
    * header Authorization = 'Bearer ' + token
    * request Session
    * method Post
    * status 200
    * def anonSession = $.sessionToken
    * print anonSession

#    * def passwordRecoveryAnswer = req.ResetPassword
    And path '/api/data/user/resetpassword/'
    And path userId = '23547'
    And header Authorization = 'Bearer ' + token
    And header Session = anonSession
    And header Content-Type = 'multipart/form-data'
    And multipart field passwordRecoveryAnswer = '7'
    * request ' '
    * method Put
    * status 200