package runner;


import com.intuit.karate.junit5.Karate;
import cucumber.api.CucumberOptions;
import org.junit.runner.RunWith;

class UsersTest {

    @Karate.Test
    Karate testUi() {
        return Karate.run("");
    }

}


