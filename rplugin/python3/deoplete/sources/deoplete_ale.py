# ============================================================================
# FILE: omni.py
# AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
# License: MIT license
# ============================================================================

from deoplete.source.base import (
    Base
)
from deoplete.util import (
    convert2candidates
)


class Source(Base):

    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'ale'
        self.mark = '[L]'
        self.rank = 100
        self.is_bytepos = True
        self.min_pattern_length = 0
        self.events = ['CompleteDone']

        self.poll_func = 'ale#completion#PollCompletionResults'
        self.position_func = 'ale#completion#FindCompletionStart'
        self.reset_func = 'ale#completion#ClearBufferResults'

    def on_event(self, context):
        if context['event'] == 'CompleteDone':
            context['completion_done'] = True

    def get_completion_position(self):
        return self.vim.call(self.position_func)

    def patch_candidates(self, candidates):
        if isinstance(candidates, dict):
            candidates = candidates['words']
        elif not isinstance(candidates, list):
            candidates = convert2candidates(candidates)

        for c in candidates:
            c['dup'] = 1

        return candidates

    def gather_candidates(self, context):
        candidates = []

        try:
            if 'initial_position' not in context:
                self.vim.call(self.reset_func)
                context['initial_position'] = self.get_completion_position()

                if context['initial_position'] < 0:
                    return []
                else:
                    context['is_async'] = True

            candidates = self.vim.call(self.poll_func)

            if 'completion_done' in context or candidates:
                context['is_async'] = False
                self.vim.call(self.reset_func)
                candidates = self.patch_candidates(candidates)

            # self.vim.command('echo localtime()')
            return candidates
        except Exception:
            self.print_error('Error occurred calling ALE')
            return None
