import unittest
import imp

ale_module = imp.load_source(
    'deoplete.sources.ale',
    '/testplugin/rplugin/python3/deoplete/sources/ale.py',
)


class VimMock(object):
    def __init__(self, call_list, call_results):
        self.__call_list = call_list
        self.__call_results = call_results

    def call(self, function, *args):
        self.__call_list.append((function, args))

        return self.__call_results.get(function, 0)


class DeopleteSourceTest(unittest.TestCase):
    def setUp(self):
        super(DeopleteSourceTest, self).setUp()

        self.call_list = []
        self.call_results = {'ale#completion#CanProvideCompletions': 1}
        self.source = ale_module.Source('vim')
        self.source.vim = VimMock(self.call_list, self.call_results)

    def test_attributes(self):
        """
        Check all of the attributes we set.
        """
        attributes = dict(
            (key, getattr(self.source, key))
            for key in
            dir(self.source)
            if not key.startswith('__')
            and key != 'vim'
            and not hasattr(getattr(self.source, key), '__self__')
        )

        self.assertEqual(attributes, {
            'input_patterns': {
                '_': r'\.\w*$',
                'rust': r'(\.|::)\w*$',
                'typescript': r'(\.|\'|")\w*$',
                'cpp': r'(\.|::|->)\w*$',
            },
            'is_bytepos': True,
            'mark': '[L]',
            'min_pattern_length': 1,
            'name': 'ale',
            'rank': 1000,
        })

    def test_complete_position(self):
        self.call_results['ale#completion#GetCompletionPositionForDeoplete'] = 2
        context = {'input': 'foo'}

        self.assertEqual(self.source.get_complete_position(context), 2)
        self.assertEqual(self.call_list, [
            ('ale#completion#GetCompletionPositionForDeoplete', ('foo',)),
        ])

    def test_request_completion_results(self):
        context = {'is_async': False}

        self.assertEqual(self.source.gather_candidates(context), [])
        self.assertEqual(context, {'is_async': True})
        self.assertEqual(self.call_list, [
            ('ale#completion#CanProvideCompletions', ()),
            ('ale#completion#GetCompletions', ('deoplete',)),
        ])

    def test_request_completion_results_from_buffer_without_providers(self):
        self.call_results['ale#completion#CanProvideCompletions'] = 0
        context = {'is_async': False}

        self.assertIsNone(self.source.gather_candidates(context), [])
        self.assertEqual(context, {'is_async': False})
        self.assertEqual(self.call_list, [
            ('ale#completion#CanProvideCompletions', ()),
        ])

    def test_refresh_completion_results(self):
        context = {'is_async': False}

        self.assertEqual(self.source.gather_candidates(context), [])
        self.assertEqual(context, {'is_async': True})
        self.assertEqual(self.call_list, [
            ('ale#completion#CanProvideCompletions', ()),
            ('ale#completion#GetCompletions', ('deoplete',)),
        ])

        context = {'is_async': True, 'is_refresh': True}

        self.assertEqual(self.source.gather_candidates(context), [])
        self.assertEqual(context, {'is_async': True, 'is_refresh': True})
        self.assertEqual(self.call_list, [
            ('ale#completion#CanProvideCompletions', ()),
            ('ale#completion#GetCompletions', ('deoplete',)),
            ('ale#completion#CanProvideCompletions', ()),
            ('ale#completion#GetCompletions', ('deoplete',)),
        ])

    def test_poll_no_result(self):
        context = {'is_async': True}
        self.call_results['ale#completion#GetCompletionResult'] = None

        self.assertEqual(self.source.gather_candidates(context), [])
        self.assertEqual(context, {'is_async': True})
        self.assertEqual(self.call_list, [
            ('ale#completion#CanProvideCompletions', ()),
            ('ale#completion#GetCompletionResult', ()),
        ])

    def test_poll_empty_result_ready(self):
        context = {'is_async': True}
        self.call_results['ale#completion#GetCompletionResult'] = []

        self.assertEqual(self.source.gather_candidates(context), [])
        self.assertEqual(context, {'is_async': False})
        self.assertEqual(self.call_list, [
            ('ale#completion#CanProvideCompletions', ()),
            ('ale#completion#GetCompletionResult', ()),
        ])

    def test_poll_non_empty_result_ready(self):
        context = {'is_async': True}
        self.call_results['ale#completion#GetCompletionResult'] = [
            {
                'word': 'foobar',
                'kind': 'v',
                'icase': 1,
                'menu': '',
                'info': '',
            },
        ]

        self.assertEqual(self.source.gather_candidates(context), [
            {
                'word': 'foobar',
                'kind': 'v',
                'icase': 1,
                'menu': '',
                'info': '',
            },
        ])
        self.assertEqual(context, {'is_async': False})
        self.assertEqual(self.call_list, [
            ('ale#completion#CanProvideCompletions', ()),
            ('ale#completion#GetCompletionResult', ()),
        ])
