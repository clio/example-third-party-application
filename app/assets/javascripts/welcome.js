function receiveMessageFromPopup(event) {
  if (event.origin !== "http://localhost:3013" || !event.isTrusted) {
    console.log("You are not worthy, received message from unknown source!");
  } else {
    if (event.data === "authentication_successful") {
      console.log(
        "Sign in was successful, redirect to the matter page.",
        event.data
      );
      window.location.href = "/matter";
    } else {
      console.log("Sign in failed.", event.data);
    }
  }
}

//Listen for message events
window.addEventListener("message", receiveMessageFromPopup, false);
