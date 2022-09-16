my $expected_question_answer_map = {
  "The correct way to answer each question is:" => {
                                                     CHECKED   => ["To put an X in the box beside the correct answer"],
                                                     UNCHECKED => [
                                                                    "To put an X in every box, except the one beside the correct answer",
                                                                    "To put an smiley-face emoji in the box beside the correct answer",
                                                                    "To delete the box beside the correct answer",
                                                                    "To delete the correct answer",
                                                                  ],
                                                   },
  "The lecturer for this class is:"             => {
                                                     CHECKED   => ["Dr Damian Conway"],
                                                     UNCHECKED => [
                                                                    "Dr Theodor Seuss Geisel",
                                                                    "Dr Sigmund Freud",
                                                                    "Dr Victor von Doom",
                                                                    "Dr Who",
                                                                  ],
                                                   },
  "The name of this class is:"                  => {
                                                     CHECKED   => ["Introduction to Perl for Programmers"],
                                                     UNCHECKED => [
                                                                    "Introduction to Perl for Programmers and Other Crazy People",
                                                                    "Introduction to Programming for Pearlers",
                                                                    "Introduction to Aussies for Europeans",
                                                                    "Introduction to Python for Slytherins",
                                                                  ],
                                                   },
}