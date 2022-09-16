my $actual_parsed_exam = {
  HEADER    => "Complete this exam by placing an 'X' in the box beside each correct\nanswer, like so:\n\n    [ ] This is not the correct answer\n    [ ] This is not the correct answer either\n    [ ] This is an incorrect answer\n    [X] This is the correct answer\n    [ ] This is an irrelevant answer\n\nScoring: Each question is worth 2 points.\n         Final score will be: SUM / 10\n\nWarning: Each question has only one correct answer. Answers to\n         questions for which two or more boxes are marked with an 'X'\n         will be scored as zero.",
  QUESTIONS => [
                 {
                   ANSWERS => [
                                { CHECKBOX => "[X]", TEXT => "Introduction to Perl for Programmers\n" },
                                {
                                  CHECKBOX => "[ ]",
                                  TEXT => "Introduction to Perl for Programmers and Other Crazy People\n",
                                },
                                {
                                  CHECKBOX => "[ ]",
                                  TEXT => "Introduction to Programming for Pearlers\n",
                                },
                                {
                                  CHECKBOX => "[ ]",
                                  TEXT => "Introduction to Aussies for Europeans\n",
                                },
                                {
                                  CHECKBOX => "[ ]",
                                  TEXT => "Introduction to Python for Slytherins\n",
                                },
                              ],
                   NUMBER  => 1,
                   TEXT    => "The name of this class is:\n",
                 },
                 {
                   ANSWERS => [
                                { CHECKBOX => "[ ]", TEXT => "Dr Theodor Seuss Geisel\n" },
                                { CHECKBOX => "[ ]", TEXT => "Dr Sigmund Freud\n" },
                                { CHECKBOX => "[ ]", TEXT => "Dr Victor von Doom\n" },
                                { CHECKBOX => "[X]", TEXT => "Dr Damian Conway\n" },
                                { CHECKBOX => "[ ]", TEXT => "Dr Who\n" },
                              ],
                   NUMBER  => 2,
                   TEXT    => "The lecturer for this class is:\n",
                 },
                 {
                   ANSWERS => [
                                {
                                  CHECKBOX => "[X]",
                                  TEXT => "To put an X in the box beside the correct answer\n",
                                },
                                {
                                  CHECKBOX => "[ ]",
                                  TEXT => "To put an X in every box, except the one beside the correct answer\n",
                                },
                                {
                                  CHECKBOX => "[ ]",
                                  TEXT => "To put an smiley-face emoji in the box beside the correct answer\n",
                                },
                                {
                                  CHECKBOX => "[ ]",
                                  TEXT => "To delete the box beside the correct answer\n",
                                },
                                { CHECKBOX => "[ ]", TEXT => "To delete the correct answer\n" },
                              ],
                   NUMBER  => 3,
                   TEXT    => "The correct way to answer each question is:\n",
                 },
               ],
}