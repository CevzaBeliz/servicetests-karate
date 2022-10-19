Feature: ServiceTests

  Background:
    * url 'https://api.sandbox.today'
    * configure ssl = true
    * configure headers = { 'accept': 'application/json', 'Content-Type': 'application/json'}
    * def req = read('classpath:requests.json')

#    #Create token with signature
#    * path '/api/auth/token'
#    * header ClientId = 'Testinium-Cloud'
#    * header Nonce = 'qasw'
#    * header Signature = 'EF6FEE6F8EDC924641C5E11A5085D437CE5C8083E07DFCA11452D332BBF3499D'
#    * method Get
#    * status 200
#    * def token = response.token
    * def token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJUZXN0aW5pdW0tQ2xvdWQiLCJqdGkiOiJjYWYyOTA4OS0xNzU3LTRmMTYtODcwNy0yMDdlYWI4NTZmZTMiLCJlbWFpbCI6ImJ1Z3JhLnVja3VzQGxpZ2FzdGF2b2sucnUiLCJnaXZlbl9uYW1lIjoiVGVzdGluaXVtLUNsb3VkIiwiSWRlbnRpdHlJZCI6IjI3IiwiQW5vbnltb3VzIjoiMjM1NDIiLCJDbGllbnRJZCI6ImNsb3VkIiwiZXhwIjoxNjQxOTcxNDg2LCJpc3MiOiJodHRwOi8vaXNzdWVyLmF0IiwiYXVkIjoiaHR0cDovL2F1ZGllbmNlLmF0In0.Y9HvaX35S1BrSYu14BNho6ZCN9yNJH1YXyV5T9eta_Q'
    * print token

    #Definition of sign param for specific user from json file
    * def Sign = req.signLigabet

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

  @BonusServiceTestKZ
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

  @ChangetheBetSettingsKZ
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

  @SettheMaxSessionTimeKZ
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

  @CashoutSingleBetKZ
  Scenario: Cash out the single bet which place the one available game

    #List the available games with filters
    And path '/api/data/games/search'
    And path pageSize  = '3'
    And path pageNumber  = '5'
    And path langId   = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200

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
    And path startIndex  = '146'
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

  @CashoutCombiBetKZ
  Scenario: Cash out the combi bet which place the 3 available games

    #List the available games with filters
    And path '/api/data/games/search'
    And path pageSize  = '3'
    And path pageNumber  = '6'
    And path langId   = '1'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    #--------------------------------------------------
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
    #--------------------------------------------------
    #Defining "combiBet" parameter pulled from json file as "placebet"
    * def placebet = req.combiBet
    #--------------------------------------------------
    #Set the individual user information from the response of signin method
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
    And path startIndex  = '38'
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

  @PlaceSystemBetKZ
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
    And path startIndex  = '70'
    And path pageSize  = '200'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    When method Get
    Then status 200
    * def lastBetSlipId = $.items[-1].id
    * print lastBetSlipId
    And match betSlipId == lastBetSlipId

  @PlaceSameBetsInDifferentSlipKZ
  Scenario: Place Bet More Than One Slip
    #Find Bets
    * path '/api/data/games/gamesbyleague/54/1'
    * header Authorization = 'Bearer ' + token
    * header Session = session
    * method Get
    * status 200

    #First Bet
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
    #Second Bet
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
    #Third Bet
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
    #Fourth Bet
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
    # startIndex
    * path startIndex = '/100'
    # pageSize
    * path pageSize = '/190'
    * method Get
    * status 200
    * def lastBet = $.items[-1:].id
    * print lastBet
    * match lastBet == BetID

  @PlaceDifferentBetsInDifferentSlipKZ
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

    #First Bet
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
    #Second Bet
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
    #Third Bet
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
    #Fourth Bet
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

    # Find Second betslip items
    * path '/api/data/games/gamesbyleague'
    And header Authorization = 'Bearer ' + token
    And header Session = session
    * path leagueId = '178'
    * path langId = '1'
    * method Get
    * status 200
    * def secondslipbets = response
    * print secondslipbets
    #First Bet
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
    #Second Bet
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
    #Third Bet
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
    #Fourth Bet
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

    #Give First Slip First Bet items
    * set bet $.[0].items[0].gameId = gameId0
    * set bet $.[0].items[0].marketId = marketId0
    * set bet $.[0].items[0].oddId = oddId0
    * set bet $.[0].items[0].marketTypeId = marketTypeId0

    #---------------------------------------------
    #Give First Slip Second Bet items
    * set bet $.[0].items[1].gameId = gameId1
    * set bet $.[0].items[1].marketId = marketId1
    * set bet $.[0].items[1].oddId = oddId1
    * set bet $.[0].items[1].marketTypeId = marketTypeId1

    #---------------------------------------------
    #Give First Slip Third Bet items
    * set bet $.[0].items[2].gameId = gameId2
    * set bet $.[0].items[2].marketId = marketId2
    * set bet $.[0].items[2].oddId = oddId2
    * set bet $.[0].items[2].marketTypeId = marketTypeId2

    #---------------------------------------------
    #Give First Slip Forth Bet items
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
    # startIndex Of Users Bet History
    * path startIndex = '/100'
    # pageSize Of Users Bet History
    * path pageSize = '/190'
    * method Get
    * status 200
    * def lastBet = $.items[-1:].id
    * print lastBet
    * match lastBet == BetID
