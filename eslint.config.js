import js from '@eslint/js'
import vue from 'eslint-plugin-vue'
import vueTsEslintConfig from '@vue/eslint-config-typescript'
import prettierConfig from '@vue/eslint-config-prettier'

export default [
  {
    ignores: ['dist/**', 'node_modules/**', '*.d.ts'],
  },
  js.configs.recommended,
  ...vue.configs['flat/recommended'],
  ...vueTsEslintConfig(),
  prettierConfig,
  {
    files: ['**/*.vue', '**/*.ts'],
    rules: {
      'vue/multi-word-component-names': 'off',
      'vue/component-name-in-template-casing': ['error', 'PascalCase'],
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/consistent-type-imports': 'error',
    },
  },
]
