import { defineAuth } from '@aws-amplify/backend';

/**
 * Define and configure your auth resource
 * @see https://docs.amplify.aws/gen2/build-a-backend/auth
 */
export const auth = defineAuth({
  loginWith: {
    email: true,
  },
  userAttributes: {
    // Atributos requeridos
    email: {
      required: true,
      mutable: true,
    },
    // Atributos opcionales
    givenName: {
      required: false,
      mutable: true,
    },
    familyName: {
      required: false,
      mutable: true,
    },
    phoneNumber: {
      required: false,
      mutable: true,
    },
  },
  // Configuración de MFA (opcional)
  multifactor: {
    mode: 'OFF',
  },
  // Configuración de recuperación de contraseña
  accountRecovery: 'EMAIL_ONLY',
});
