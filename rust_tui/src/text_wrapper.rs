pub fn get_story_text(node_id: u32, original_node_text: &str) -> String {
    match node_id {
        1 => "Hello Freshman! I'm your great friend ChatGPT and I will guide you through your first year of collage. 
              \nOn your path to career and success (tf), you will have to make many decisions and these decisions will be followed by serious consequences. 
              \nI almost forgot to mention—you're addicted to gambling (though you prefer the term 'enthusiast'). But we'll come back to it when the time is right. 
              \nChoose wisely...".to_string(),

        11 => "Your first classes start tomorrow, but you noticed in the group chat with your future classmates, 
                \nthat they're planning a welcome hangout in the student park.".to_string(),

        111 => "You stay home to rest and prepare for tomorrow. 
                \nPeaceful evening, but you feel a bit left out.".to_string(),

        112 => "You decide to join the group in the student park. 
                \nThe atmosphere is great and you make some friends.".to_string(),

        5 => "You're alone in your room, slightly bored but today is the Champions League.... 
              \nWondering whether to turn up the excitement of watching a little and place a small bet?".to_string(),

        10 => "People in the park start betting among themselves on who can drink beer the fastest.... 
              \nAre you joining?".to_string(),

        1111 => "You're getting ready for bed, but suddenly you hear the phone ringing, it's your old friend - Mathew. 
                \nWhen you answer the phone, Mathew asks you to meet him in 30 minute. 
                \nIt's a little strange because, after all, you haven't spoken in few years.".to_string(),

        1121 => "It is late, and you're still sitting in the park, quietly drinking a beer. 
                 \nSuddenly, a grumpy man comes up to you and tells you to leave the park, 
                 \nthreatening to call the police.".to_string(),

        11111 => "You stayed at home — it was a bit boring at times, and you did feel a little disconnected from everything. 
                  \nBut honestly, it gave you the chance to rest and reset. 
                  \nNow you feel recharged and ready to dive into university life at full speed.".to_string(),        

        11112 => "After a short hesitation you decide to go. Night bus rides have their own strange vibe. 
                  \nWhen you arrive, Mathew is waiting for you at the bus stop. 
                  \nHe looks almost the same as before, only a little more tired.

                 \nAfter a classic small-talk, he gets to the point: 
                 \nI know this may sound strange, but I need your help... with the remodeling. Seriously. 
                 \nToday an impulse came over me that I need to finally clean up this mess. And as soon as I saw that you were in the area, I thought: gee, you've always been helpful, and it'll be fun to get together years later.

                 \nYou agree without a problem. 
                 \nFor an hour you move shelves, carry out boxes, rearrange your desk while sipping a beer and talking about the good old days. 
                 \nMathew becomes more lively with each passing moment. The atmosphere becomes relaxed, familiar, as if you had never lost touch.

                 \nWhen you finish and sit on the floor, he looks at you and says a little quieter:
                 \n- Thanks. Seriously. And you know what... I'll get back to you on one more thing. 
                 \nNot now, but soon. I think I might need you... a little more than with the cabinets.".to_string(),

        11211 => "You stood up slowly and responded in a calm but firm tone. 
                 \nYou tried to explain that you weren`t bothering anyone and that you weren`t doing anything wrong. 
                 \nThe conversation escalated quickly — voices were raised, and tension grew. 
                 \nSomeone from your group muttered a snarky comment in the background, which didn`t help.
                 \nThe man`s face tightened, clearly frustrated, but eventually, realizing you wouldn`t back down, 
                 \nhe muttered something under his breath and walked away, disappearing into the trees. 
                 \nThe tension slowly faded, and someone cracked open another beer.".to_string(),

        11212 => "You chose not to react and turned your attention back to the conversation with your friends. 
                  \nThe man stood there for a moment longer, as if waiting for someone to respond. 
                  \nThen, suddenly, one of the drunker members of your group shouted something incoherent and grabbed him by the sleeve.
                  \nThe man flinched, took a step back, and scanned the whole group carefully — like he was trying to assess who he was really dealing with.
                  \nWithout saying a word, he turned around and quickly walked off into the night. 
                  \nThe group fell quiet for a moment, the mood slightly shaken — except for the drunk one, who laughed as if nothing had happened.".to_string(),

        111111 => "You chose peace and preparation. 
                   \nWhile others went out and got tangled in chaos, you stayed back, recharged, and began your student life with a clear head. 
                   \nSometimes, the best adventure is a quiet night and a good night`s sleep. 
                   \n\n--- END OF CHAPTER 1---".to_string(),

        111121 => "A phone call from the past led you somewhere unexpected — not dramatic, not wild, but meaningful. 
                   \nYou helped, you listened, and you reconnected. 
                   \nSometimes, the most valuable things come from simply showing up. 
                   \n\n--- END OF CHAPTER 1---".to_string(),

        112111 => "You stood your ground and didn`t let someone ruin the moment. 
                  \nIt got loud, but you handled it. 
                  \nThat night, you left with a story, a little adrenaline, and maybe a bit more respect — from others, and yourself. 
                  \n\n--- END OF CHAPTER 1---".to_string(),

        112121 => "You tried to avoid the drama — but someone else stirred the pot. 
                   \nChaos briefly took over, but the night ended in a strange, shaky peace. 
                   \nYou walked away a little rattled, but still intact. 
                   \nLesson learned: not every party ends smoothly. 
                   \n\n--- END OF CHAPTER 1---".to_string(),


        _ => format!("Original Node Info (ID: {}): '{}'", node_id, original_node_text),
    }
}

pub fn get_choice_text(node_id: u32, choice_id: u8, original_choice_text: &str) -> String {
    match (node_id, choice_id) {
        (1, 1) => "[1] Let's begin this journey!".to_string(),

        (11, 1) => "[1] Stay at home, and prepare for classes.".to_string(),
        (11, 2) => "[2] Hangout and meet new friends.".to_string(),

        (111, 1) => "[1] Continue.".to_string(),

        (112, 1) => "[1] Continue.".to_string(),

        (5, 1) => "[1] Bet on match".to_string(),
        (5, 2) => "[2] Save money this time".to_string(),

        (10, 1) => "[1] Let's do it!".to_string(),
        (10, 2) => "[2] Meaby next time.".to_string(),

        (1111, 1) => "[1] You make up something and go to sleep.".to_string(),
        (1111, 2) => "[2] Get out of bed and leave the house.".to_string(),

        (1121, 1) => "[1] Tell him to mind his own business.".to_string(),
        (1121, 2) => "[2] Politely apologize and walk away.".to_string(),

        (11112, 1) => "[1] Talk to mathew for a while longer and go back home.".to_string(),

        (11111, 1) => "[1] Go to sleep...".to_string(),

        (11211, 1) => "[1] It`s been an eventful day, but it`s getting really late, so you decide to head home.".to_string(),

        (11212, 1) => "[1] The whole situation was a bit overwhelming — enough excitement for one day. You decide it`s time to head home.".to_string(),
        
        _ => format!("Choice ID: {}, Original Choice Text: '{}'", choice_id, original_choice_text),
    }
}
