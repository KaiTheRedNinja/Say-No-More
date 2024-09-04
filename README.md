# Say No More

A game based on Taboo, where players try and get their teammates to guess a word 
without them saying any forbidden words.

Say No More is powered by OpenAI's ChatGPT, so you'll never (ish) see duplicate words.

# Running

Create a `Secrets.swift` file at `Say No More/App/Secrets.swift`. It should contain the following:
```swift
enum Secrets {
    static let key: String = "YOUR_KEY_HERE"
}
```

Then, run it as you would a normal Xcode iOS project.
