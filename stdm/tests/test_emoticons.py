import unittest

import emoticons


class TestMethods(unittest.TestCase):
    def test_add(self):
        self.assertEqual(emoticons.smile(), ":)")


if __name__ == '__main__':
    unittest.main()