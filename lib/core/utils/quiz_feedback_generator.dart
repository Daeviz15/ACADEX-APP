import 'dart:math';

/// Generates custom, sassy, and dynamic GenZ-styled feedback responses
/// to dramatically improve user DAU retention during quizzes.
class QuizFeedbackGenerator {
  static final _random = Random();

  static const List<String> _strikeOneFails = [
    "Did you just guess, {name}? 💀 Because that was painfully wrong.",
    "Oof. The math wasn't mathing there at all, {name}. Try again.",
    "Not even close, {name}. Did you even read the question? 🤨",
    "{name}, my grandmother could have gotten that right. Read!",
    "Are you clicking randomly, {name}? Because honestly... yikes.",
    "Error 404: Logic not found, {name}. 💻",
    "{name}, blink twice if you need help with this one.",
    "I'm judging you silently, {name}. Very silently. 😑",
    "Did you misclick? Tell me you misclicked, {name}. 🖱️",
    "{name}, I see we are choosing violence against our grades today.",
    "That answer was definitely a choice, {name}... just not the right one.",
    "Take a deep breath, read it again, and do better, {name}. 🧘‍♂️",
    "{name}, are you testing my patience or your knowledge?",
    "Yikes! We love the confidence, but not the accuracy, {name}. 😭",
    "Let's pretend that didn't happen, {name}. Try again.",
    "{name}, you're breaking my heart with these answers. 💔",
    "No, {name}. Just no. 🛑",
    "I've seen better answers from a magic 8-ball, {name}. 🎱",
    "Did you sleep through this class, {name}? Wake up!",
    "A swing and a massive miss, {name}. ⚾💨"
  ];

  static const List<String> _strikeTwoFails = [
    "{name}, please tell me you're just warming up. This is embarrassing. 🤦‍♂️",
    "Okay {name}, now you're just button mashing. Stop it.",
    "Did you even read the explanation earlier, {name}? Are you allergic to reading? 😭",
    "{name}... I'm genuinely concerned for your GPA right now.",
    "Bro. Come on {name}. My logic circuits are crying for you. 💀",
    "{name}, at this point, you're just mathematically eliminating yourself.",
    "I'm this close 🤏 to locking the screen, {name}.",
    "Two strikes, {name}. Are you trying to set a record for consecutive fails?",
    "{name}, respectfully... what are you doing? 🤨",
    "This isn't a casino, {name}. Stop gambling your answers! 🎰",
    "Is your screen blurry? Do you need glasses, {name}? 👓",
    "{name}, I'm calling your professor right now. 📞",
    "It's giving 'I skipped every lecture', {name}. 🚩",
    "{name}, please tell me your cat walked across the keyboard.",
    "I have lost all faith in your academic comeback, {name}. 📉"
  ];

  static const List<String> _strikeThreeFails = [
    "{name}, is this really how you plan to graduate? 😂 BE SERIOUS!",
    "I'm putting you on timeout, {name}. Read the absolute explanation!",
    "It's giving 'I didn't study at all and I'm hoping for a miracle', {name}. 🥴",
    "Okay, {name}, time to pack it up. The textbook is calling your name loud and clear. 🎒",
    "{name}, my servers carry more weight than this pathetic attempt. Wake up! 🤖",
    "Three strikes, {name}. You're out. The academic weapon is currently jammed. 🚫",
    "{name}, I'm officially filing a missing persons report for your brain cells. 🚨",
    "Just close the app, {name}. Try again tomorrow when you have energy. 🛌",
    "{name}, I'm not mad, I'm just incredibly disappointed. 😔",
    "Is this a social experiment? Because you're failing it, {name}. 🧪",
    "{name}, you are single-handedly lowering the class average. 📉",
    "I would give you a hint, but I don't think it would help, {name}. 🤷‍♂️",
    "{name}, this is an academic disaster class. Mayday! ✈️📉",
    "You have successfully achieved a streak of absolute zero, {name}. 🥶"
  ];

  static const List<String> _firstCorrect = [
    "Okay okay, {name} is locked in! 🎯 Brain cells activated!",
    "Correct! We love to see the intelligence jumping out, {name}.",
    "Snatched that answer! You actually know your stuff, {name}. ✨",
    "Ate that question and left absolutely NO crumbs, {name}! 🍽️",
    "Spot on, {name}. Your brain is massive today!",
    "Love this for you, {name}! Correct! 🎉",
    "{name} understood the assignment! 📝✅",
    "Look at you go, {name}! Big brain energy. 🧠💥",
    "Period. That's the one, {name}. 💅",
    "{name} is cooking! Someone get them an apron! 👨‍🍳🔥",
    "Nailed it! {name} for the win! 🔨",
    "Absolutely flawlessly correct, {name}. 🌟",
    "You dropped this, {name} 👑... oh wait, save it for the streak.",
    "Easy work for {name}! 💼",
    "That's exactly right. The studying is paying off, {name}! 📚"
  ];

  static const List<String> _streakCorrect = [
    "{name} IS ON FIRE 🔥🔥 Somebody call the fire department right now!",
    "AN ACADEMIC WEAPON! {name} is literally unstoppable. Einstein is shaking! 🚀",
    "{name}, did you secretly steal the answer key? 😂 Absolute Genius behavior!",
    "Flawless victory, {name}! They shouldn't even test you anymore! 👑",
    "You dropped this, {name} 👑. You are the academic standard right now!",
    "Who let {name} cook?! This hot streak is legendary. ☄️",
    "{name} is entering their villain era. Destroying these questions! 🦹‍♂️",
    "Unreal! {name} is putting the entire class on their back! 🎒🔥",
    "Is {name} a supercomputer in disguise? Because WOW! 💻🤖",
    "The streak is alive! {name} is farming straight A's! 🚜💯",
    "Stop setting the bar so high, {name}! Other students are crying. 😭📈",
    "{name} has entered the Matrix. He sees the code! 🕶️💊",
    "I bow to your supreme intellect, {name}. 🙇‍♂️",
    "Can't stop, won't stop! {name} is on an absolute tear! 🌪️",
    "Give {name} their degree already! Skip the finals! 🎓📜"
  ];

  /// Generates the correct response based on the users state and name.
  static String getFeedback({
    required String name,
    required bool isCorrect,
    required int failStreak,
    required int winStreak,
  }) {
    // Clean up name (capitalize first letter, fall back if empty)
    String safeName = "Scholar";
    if (name.isNotEmpty) {
      safeName = name.split(" ")[0]; // Just use first name
      if (safeName.length > 1) {
        safeName = safeName[0].toUpperCase() + safeName.substring(1).toLowerCase();
      }
    }

    String template;

    if (isCorrect) {
      if (winStreak >= 3) {
        template = _streakCorrect[_random.nextInt(_streakCorrect.length)];
      } else {
        template = _firstCorrect[_random.nextInt(_firstCorrect.length)];
      }
    } else {
      if (failStreak == 1) {
        template = _strikeOneFails[_random.nextInt(_strikeOneFails.length)];
      } else if (failStreak == 2) {
        template = _strikeTwoFails[_random.nextInt(_strikeTwoFails.length)];
      } else {
        template = _strikeThreeFails[_random.nextInt(_strikeThreeFails.length)];
      }
    }

    return template.replaceAll("{name}", safeName);
  }
}
