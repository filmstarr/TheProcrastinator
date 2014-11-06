<?php

//Check we have a user and an action
if (!isset($_REQUEST["action"]) || !isset($_REQUEST["udid"]))
{
  die("0");
}

//Get our user and action
$action = $_REQUEST["action"];
$udid = $_REQUEST["udid"];

//Check the user is valid
if (strlen($udid) != 40)
{
  die("0");
}

//Call the action
if ($action == "submit_question") {
  SubmitQuestion();
  echo "1"; 
}
else if ($action == "submit_answer") {
  SubmitAnswer();
  echo "1";
}
else if ($action == "retrieve_questions") RetrieveQuestions();
else if ($action == "retrieve_answers") RetrieveAnswers();
else if ($action == "retrieve_question") RetrieveQuestion();
else if ($action == "retrieve_answer") RetrieveAnswer();
else if ($action == "hide_answer") HideAnswer();
else if ($action == "delete_question") DeleteQuestion();
else if ($action == "submit_question_retrieve_questions") {
  SubmitQuestion();
  RetrieveQuestions();
}
else if ($action == "submit_answer_retrieve_answer") {
  SubmitAnswer();
  RetrieveAnswer();
}
else { die("0"); }

//Submit a new question
function SubmitQuestion()
{
  global $udid;

  //Check that we have a question
  if (!isset($_REQUEST["question"]) || $_REQUEST["question"] == "" || $_REQUEST["question"] == "?")
  {
    die("0");
  }

  //Connect to database
  $connection = DbConnection();

  //Prevent SQL invection attack in variables
  $udid = mysql_real_escape_string($udid);
  $question = mysql_real_escape_string($_REQUEST["question"]);

  //Remove delimiters
  $question = str_replace("\n", " ", $question);
  $question = str_replace("\t", " ", $question);
 
  //Check for duplicate questions submitted in the last day
  $query = "SELECT * FROM questions WHERE udid = '" . $udid . "' AND question = '" . $question . "' AND date_asked >= DATE_ADD(UTC_TIMESTAMP(),INTERVAL -1 DAY);";
  $result = mysql_query($query);
  $questionCount = mysql_num_rows($result);
    
  //If we have 1 question
  if($questionCount == 0 && $question != 'Please enter your YES/NO question here...')
  {
    //Submit our question
    $result = mysql_query("INSERT INTO questions(udid,date_asked,question) " .
        "VALUES ('" . $udid . "',UTC_TIMESTAMP(),'" . $question . "');");
  }
  else
  {
    mysql_close($connection);
    die("0");
  }

  //Close the connection
  mysql_close($connection);
}

//Answer an existing question
function SubmitAnswer()
{
  global $udid;

  //Check that we have a valid question and answer
  if (!isset($_REQUEST["question_id"])  || !isset($_REQUEST["answer"]))
  {
     die("0");
  }

  //Connect to database
  $connection = DbConnection();

  //Prevent SQL invection attack in variables
  $udid = mysql_real_escape_string($udid);
  $questionID = mysql_real_escape_string($_REQUEST["question_id"]);
  $answer = mysql_real_escape_string($_REQUEST["answer"]);
  
  //Delete any existing answer
  $query =  "DELETE FROM answers WHERE question_id = '" . $questionID . "' AND udid = '" . $udid . "';";
  $result = mysql_query($query);

  //Count the number of questions with the specified id
  $query = "SELECT * FROM questions WHERE id = '" . $questionID . "';";
  $result = mysql_query($query);
  $questionCount = mysql_num_rows($result);

  //If we have 1 question
  if($questionCount == 1)
  {
    $query = "INSERT INTO answers(question_id,udid,answer) VALUES ('" . $questionID . "','" . $udid . "','" . $answer . "'); ";
    $result = mysql_query($query);
  }
  else
  {
    mysql_close($connection);
    die("0");
  }

  //Close the connection
  mysql_close($connection);
}

//Retrieve a users questions
function RetrieveQuestions()
{
  global $udid;

  //Connect to database
  $connection = DbConnection();

  //Prevent SQL invection attack
  $udid = mysql_real_escape_string($udid);
  if (isset($_REQUEST["seed"]))
  {
     $seed = $_REQUEST["seed"];
     $seed = mysql_real_escape_string($seed);
  }

  if (isset($_REQUEST["batch_size"]))
  {
     $batch = $_REQUEST["batch_size"];
     $batch = mysql_real_escape_string($batch);
  }

  //Get our query result
  $result = mysql_query("SELECT q.id,q.question" .
			",(SELECT CONCAT(CAST(IF(2*SUM(a.answer) != COUNT(a.answer),ROUND(SUM(a.answer)/COUNT(a.answer),0),2) AS CHAR), '\t',CAST(SUM(a.answer) AS CHAR), '\t',CAST(COUNT(a.answer) AS CHAR)) FROM answers a WHERE q.id = a.question_id AND q.udid != a.udid AND a.hidden = 0) answer " .
			"FROM questions q " .
			"WHERE q.udid = '" . $udid . "' " .
			(isset($seed) ? "AND q.id < " . $seed . " " : "") .
			"ORDER BY date_asked DESC, q.id DESC " .
			(isset($batch) ? "LIMIT " . $batch . "" : "") .
			"");

  //Create our results string
  $output = "";
  while ($row = mysql_fetch_array($result)) {
    $answer = ($row{"answer"} == "" || is_null($row{"answer"})) ? "2\t0\t0" : $row{"answer"};
    $output .= $row{"id"} . "\t" . $row{"question"} . "\t" . $answer . "\n";
  }

  //Get the users first question
  $result = mysql_query("SELECT MIN(q.id) id FROM questions q WHERE q.udid = '" . $udid . "';");

  //Create our results string
  while ($row = mysql_fetch_array($result)) {
    $output .= "first question:" . $row{"id"};
  }

  //Output our results
  echo stripslashes($output);

  //Close the connection
  mysql_close($connection);
}

//Retrieve a users answers
function RetrieveAnswers()
{
  global $udid;

  //Connect to database
  $connection = DbConnection();

  //Prevent SQL invection attack
  $udid = mysql_real_escape_string($udid);
  if (isset($_REQUEST["seed"]))
  {
     $seed = $_REQUEST["seed"];
     $seed = mysql_real_escape_string($seed);
  }

  if (isset($_REQUEST["batch_size"]))
  {
     $batch = $_REQUEST["batch_size"];
     $batch = mysql_real_escape_string($batch);
  }

  //Get our query result
  $result = mysql_query("SELECT q.id,q.question" .
			",(SELECT ROUND(a.answer,0) FROM answers a WHERE q.id = a.question_id AND a.udid = '" . $udid . "' AND a.hidden = 0) answer " .
			",(SELECT CONCAT(CAST(SUM(a.answer) AS CHAR), '\t',CAST(COUNT(a.answer) AS CHAR)) FROM answers a WHERE q.id = a.question_id AND q.udid != a.udid AND a.hidden = 0) totals " .
			"FROM questions q " .
			"WHERE q.udid != '" . $udid . "' " .
			"AND q.id NOT IN (SELECT a.question_id FROM answers a WHERE a.udid = '" . $udid . "' AND a.hidden = 1) " .
			(isset($seed) ? "AND q.id < " . $seed . " " : "") .
			"ORDER BY date_asked DESC, q.id DESC " .
			(isset($batch) ? "LIMIT " . $batch . "" : "") .
			"");

  //Create our results string
  $output = "";
  while ($row = mysql_fetch_array($result)) {
    $answer = ($row{"answer"} == "" || is_null($row{"answer"})) ? "2" : $row{"answer"};
    $totals = ($row{"totals"} == "" || is_null($row{"totals"})) ? "0\t0" : $row{"totals"};
    $output .= $row{"id"} . "\t" . $row{"question"} . "\t" . $answer . "\t" . $totals . "\n";
  }

  //Get the users first question
  $result = mysql_query("SELECT MIN(q.id) id FROM questions q WHERE q.udid != '" . $udid . "';");

  //Create our results string
  while ($row = mysql_fetch_array($result)) {
    $output .= "first question:" . $row{"id"};
  }

  //Output our results
  echo stripslashes($output);

  //Close the connection
  mysql_close($connection);
}

//Retrieve a single user question
function RetrieveQuestion()
{
  global $udid;

  //Check that we have a valid question
  if (!isset($_REQUEST["question_id"]))
  {
     die("0");
  }

  //Connect to database
  $connection = DbConnection();

  //Prevent SQL invection attack in variables
  $udid = mysql_real_escape_string($udid);
  $questionID = mysql_real_escape_string($_REQUEST["question_id"]);

  //Get our query result
  $result = mysql_query("SELECT q.id,q.question" .
			",(SELECT CONCAT(CAST(IF(2*SUM(a.answer) != COUNT(a.answer),ROUND(SUM(a.answer)/COUNT(a.answer),0),2) AS CHAR), '\t',CAST(SUM(a.answer) AS CHAR), '\t',CAST(COUNT(a.answer) AS CHAR)) FROM answers a WHERE q.id = a.question_id AND q.udid != a.udid AND a.hidden = 0) answer " .
			"FROM questions q " .
			"WHERE q.udid = '" . $udid . "' " .
			"AND q.id = '" . $questionID . "' " .
			"");

  //Create our results string
  $output = "0";
  while ($row = mysql_fetch_array($result)) {
    $answer = ($row{"answer"} == "" || is_null($row{"answer"})) ? "2\t0\t0" : $row{"answer"};
    $output = $row{"id"} . "\t" . $row{"question"} . "\t" . $answer;
  }

  //Output our results
  echo stripslashes($output);

  //Close the connection
  mysql_close($connection);
}

//Retrieve a single user answer
function RetrieveAnswer()
{
  global $udid;

  //Check that we have a valid question
  if (!isset($_REQUEST["question_id"]))
  {
     die("0");
  }

  //Connect to database
  $connection = DbConnection();

  //Prevent SQL invection attack in variables
  $udid = mysql_real_escape_string($udid);
  $questionID = mysql_real_escape_string($_REQUEST["question_id"]);

  //Get our query result
  $result = mysql_query("SELECT q.id,q.question" .
			",(SELECT ROUND(a.answer,0) FROM answers a WHERE q.id = a.question_id AND a.udid = '" . $udid . "' AND a.hidden = 0) answer " .
			",(SELECT CONCAT(CAST(SUM(a.answer) AS CHAR), '\t',CAST(COUNT(a.answer) AS CHAR)) FROM answers a WHERE q.id = a.question_id AND q.udid != a.udid AND a.hidden = 0) totals " .
			"FROM questions q " .
			"WHERE q.udid != '" . $udid . "' " .
			"AND q.id = '" . $questionID . "' " .
		       	"AND IFNULL((SELECT a.hidden FROM answers a WHERE a.udid = '" . $udid . "' AND a.question_id = '" . $questionID . "'),0) != 1 " .
			"");

  //Create our results string
  $output = "0";
  while ($row = mysql_fetch_array($result)) {
    $answer = ($row{"answer"} == "" || is_null($row{"answer"})) ? "2" : $row{"answer"};
    $totals = ($row{"totals"} == "" || is_null($row{"totals"})) ? "0\t0" : $row{"totals"};
    $output = $row{"id"} . "\t" . $row{"question"} . "\t" . $answer . "\t" . $totals;
  }

  //Output our results
  echo stripslashes($output);

  //Close the connection
  mysql_close($connection);
}

//Hide a question from a user
function HideAnswer()
{
  global $udid;

  //Check that we have a valid question and answer
  if (!isset($_REQUEST["question_id"]))
  {
     die("0");
  }

  //Connect to database
  $connection = DbConnection();

  //Prevent SQL invection attack in variables
  $udid = mysql_real_escape_string($udid);
  $questionID = mysql_real_escape_string($_REQUEST["question_id"]);
  
  //Delete any existing answer
  $query =  "DELETE FROM answers WHERE question_id = '" . $questionID . "' AND udid = '" . $udid . "';";
  $result = mysql_query($query);

  //Count the number of questions with the specified id
  $query = "SELECT * FROM questions WHERE id = '" . $questionID . "';";
  $result = mysql_query($query);
  $questionCount = mysql_num_rows($result);

  //If we have 1 question
  if($questionCount == 1)
  {
    $query = "INSERT INTO answers(question_id,udid,answer,hidden) VALUES ('" . $questionID . "','" . $udid . "','" . $answer . "',1); ";
    $result = mysql_query($query);
    echo "1";
  }
  else
  {
    mysql_close($connection);
    die("0");
  }

  //Close the connection
  mysql_close($connection);
}

//Delete a question
function DeleteQuestion()
{
  global $udid;

  //Check that we have a valid question
  if (!isset($_REQUEST["question_id"]))
  {
     die("0");
  }

  //Connect to database
  $connection = DbConnection();

  //Prevent SQL invection attack in variables
  $udid = mysql_real_escape_string($udid);
  $questionID = mysql_real_escape_string($_REQUEST["question_id"]);

  //Count the number of questions with the specified id
  $query = "SELECT * FROM questions WHERE id = '" . $questionID . "' AND udid = '" . $udid . "';";
  $result = mysql_query($query);
  $questionCount = mysql_num_rows($result);

  //If we have 1 question
  if($questionCount == 1)
  {
    //Delete any existing answers
    $query =  "DELETE FROM answers WHERE question_id = '" . $questionID . "';";
    $result = mysql_query($query);

    //Delete the question
    $query =  "DELETE FROM questions WHERE id = '" . $questionID . "' AND udid = '" . $udid . "';";
    $result = mysql_query($query);
    echo "1";
  }
  else
  {
    mysql_close($connection);
    die("0");
  }

  //Close the connection
  mysql_close($connection);
}


//Create a database connection
function DbConnection()
{
  //Connection settings
  $hostname = "localhost";
  $username = "username";
  $password = "password";

  //Create connection
  $connection = mysql_connect($hostname, $username, $password) 
    or die("Unable to connect to database");

  //Choose database
  $selected = mysql_select_db("database",$connection) 
    or die("Database requested doesn't exist");

  //Return our connection
  return $connection;
}

?>