
var database = firebase.database();

function createNewClass() {
    var rootRef = database.ref();
    var classRef = rootRef.child('Classes');
    var newClassRef = classRef.push();

    var classNameString = document.getElementById("class").value;
    var phraseNameString = document.getElementById("phrase").value;
    var code = newClassRef.key;    
    console.log(code)
    newClassRef.set({
        className: classNameString,
        Phrase:{
            phraseName: phraseNameString
        }
    });
    alert("Success\nClass created successfully, your code is: "+ code+"\nPrint the following page.");
    var element = document.getElementById("print-code");
    element.classList.toggle();
}

function errData(err) {
    console.log("Error");
    console.log(err);
}
function writeToDatabase(data) {

}