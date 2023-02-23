/* eslint-disable no-undef -- Until https://github.com/ember-cli/eslint-plugin-ember/issues/1747 is resolved... */
/* eslint-disable simple-import-sort/imports,padding-line-between-statements,decorator-position/decorator-position -- Can't fix these manually, without --fix working in .gts */

import { find, fillIn, render, setupOnerror } from '@ember/test-helpers';
import { module, test } from 'qunit';

import TextareaField from '@crowdstrike/ember-toucan-core/components/form/textarea-field';
import { setupRenderingTest } from 'test-app/tests/helpers';

module('Integration | Component | TextareaField', function (hooks) {
  setupRenderingTest(hooks);

  test('it renders', async function (assert) {
    await render(<template>
      <TextareaField @label="Label" data-textarea />
    </template>);

    assert.dom('[data-label]').hasText('Label');

    assert
      .dom('[data-hint]')
      .doesNotExist(
        'Expected hint block not to be displayed as a hint was not provided'
      );

    assert.dom('[data-textarea]').hasTagName('textarea');
    assert.dom('[data-textarea]').hasAttribute('id');
    assert.dom('[data-textarea]').hasClass('text-titles-and-attributes');

    assert
      .dom('[data-error]')
      .doesNotExist(
        'Expected hint block not to be displayed as an error was not provided'
      );
  });

  test('it renders with a hint', async function (assert) {
    await render(<template>
      <TextareaField @label="Label" @hint="Hint text" data-textarea />
    </template>);

    let hint = find('[data-hint]');

    assert.dom(hint).hasText('Hint text');
    assert.dom(hint).hasAttribute('id');

    let hintId = hint?.getAttribute('id') || '';
    assert.ok(hintId, 'Expected hintId to be truthy');

    let describedby =
      find('[data-textarea]')?.getAttribute('aria-describedby') || '';
    assert.ok(
      describedby.includes(hintId),
      'Expected hintId to be included in the aria-describedby'
    );
  });

  test('it renders with an error', async function (assert) {
    await render(<template>
      <TextareaField @label="Label" @error="Error text" data-textarea />
    </template>);

    let error = find('[data-error]');

    assert.dom(error).hasText('Error text');
    assert.dom(error).hasAttribute('id');

    let errorId = error?.getAttribute('id') || '';
    assert.ok(errorId, 'Expected errorId to be truthy');

    let describedby =
      find('[data-textarea]')?.getAttribute('aria-describedby') || '';
    assert.ok(
      describedby.includes(errorId),
      'Expected errorId to be included in the aria-describedby'
    );

    assert.dom('[data-textarea]').hasAttribute('aria-invalid', 'true');
  });

  test('it sets aria-describedby when both a hint and error are provided using the hint and errorIds', async function (assert) {
    await render(<template>
      <TextareaField
        @label="Label"
        @error="Error text"
        @hint="Hint text"
        data-textarea
      />
    </template>);

    let errorId = find('[data-error]')?.getAttribute('id') || '';
    assert.ok(errorId, 'Expected errorId to be truthy');

    let hintId = find('[data-hint]')?.getAttribute('id') || '';
    assert.ok(hintId, 'Expected hintId to be truthy');

    assert
      .dom('[data-textarea]')
      .hasAttribute('aria-describedby', `${errorId} ${hintId}`);
  });

  test('it disables the textarea using `@isDisabled`', async function (assert) {
    await render(<template>
      <TextareaField @label="Label" @isDisabled={{true}} data-textarea />
    </template>);

    assert.dom('[data-textarea]').isDisabled();
    assert.dom('[data-textarea]').hasClass('text-disabled');
  });

  test('it spreads attributes to the underlying textarea', async function (assert) {
    await render(<template>
      <TextareaField
        @label="Label"
        placeholder="Placeholder text"
        data-textarea
      />
    </template>);

    assert
      .dom('[data-textarea]')
      .hasAttribute('placeholder', 'Placeholder text');
  });

  test('it sets the value attribute via `@value`', async function (assert) {
    await render(<template>
      <TextareaField @label="Label" @value="tony" data-textarea />
    </template>);

    assert.dom('[data-textarea]').hasValue('tony');
  });

  test('it calls `@onChange` when input is received', async function (assert) {
    assert.expect(7);

    let handleChange = (value: string, e: Event | InputEvent) => {
      assert.strictEqual(value, 'test', 'Expected input to match');
      assert.ok(e, 'Expected `e` to be available as the second argument');
      assert.ok(e.target, 'Expected direct access to target from `e`');
      assert.step('handleChange');
    };

    await render(<template>
      <TextareaField @label="Label" @onChange={{handleChange}} data-textarea />
    </template>);

    assert.verifySteps([]);

    await fillIn('[data-textarea]', 'test');

    assert.verifySteps(['handleChange']);

    assert.dom('[data-textarea]').hasValue('test');
  });

  test('it applies the provided `@rootTestSelector` to the data-root-field attribute', async function (assert) {
    await render(<template>
      <TextareaField
        @label="Label"
        @rootTestSelector="selector"
        data-textarea
      />
    </template>);

    assert.dom('[data-root-field="selector"]').exists();
  });

  test('it throws an assertion error if no `@label` is provided', async function (assert) {
    assert.expect(1);

    setupOnerror((e: Error) => {
      assert.ok(
        e.message.includes('A "@label" argument is required'),
        'Expected assertion error message'
      );
    });

    await render(<template>
      {{! @glint-expect-error: we are not providing @label, so this is expected }}
      <TextareaField />
    </template>);
  });
});