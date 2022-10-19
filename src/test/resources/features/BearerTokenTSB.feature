Feature: Create Token
 Background:
   * url 'https://test-api.ligabet.com'
   * configure ssl = true
   * def req = read('classpath:requests.json')

  @createToken
  Scenario: Create Token

    #Create token with signature
    * path '/api/auth/token'
    * header ClientId = 'Testinium-Cloud'
    * header Nonce = 'aa'
    * header Signature = '87080196EE3AD1E024122B967CD192DDAC699E82DB3EF2F32EC4D86FA2D30F26'
    * method Get
    * status 200
    * def token = response.token
    #* def token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJCZWxpeiIsImp0aSI6IjViYzU3ZDEwLWRlYTgtNDgyNC1hOTUyLTQwYjQ4ZDFhZDc5OSIsImVtYWlsIjoiYmVsaXoubmFsaW5jaW9nbHVAbGlnYXN0YXZvay5ydSIsImdpdmVuX25hbWUiOiJUZXN0aW5pdW1BUEktc21hcnR3ZWIiLCJJZGVudGl0eUlkIjoiMjQiLCJBbm9ueW1vdXMiOiIzNTE3IiwiQ2xpZW50SWQiOiIzNTYyIiwiZXhwIjoxNjQxNjIzMzg0LCJpc3MiOiJodHRwOi8vaXNzdWVyLmF0IiwiYXVkIjoiaHR0cDovL2F1ZGllbmNlLmF0In0.IxrS7CC-t4ybxqQ-Or4Fs6SBCjN65o3d6qisnNqO0l8'
    * print token

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


      
