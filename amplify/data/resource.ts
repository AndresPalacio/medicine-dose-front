import { type ClientSchema, a, defineData } from '@aws-amplify/backend';

/*== STEP 1 ===============================================================
The section below creates a User database table with user profile fields.
The authorization rule below specifies that only authenticated users can
"create", "read", "update", and "delete" their own "User" records.
=========================================================================*/
const schema = a.schema({
  User: a
    .model({
      email: a.string().required(),
      username: a.string().required(),
      firstName: a.string(),
      lastName: a.string(),
      phoneNumber: a.string(),
      profilePicture: a.string(),
      isEmailVerified: a.boolean().default(false),
      lastLoginAt: a.datetime(),
      createdAt: a.datetime(),
      updatedAt: a.datetime(),
    })
    .authorization((allow) => [
      allow.owner().to(['create', 'read', 'update', 'delete']),
    ]),
  
  // Modelo para citas médicas (opcional, ya que tienes saved_appointments)
  Appointment: a
    .model({
      userId: a.string().required(),
      title: a.string().required(),
      description: a.string(),
      date: a.datetime().required(),
      status: a.enum(['scheduled', 'completed', 'cancelled']),
      notes: a.string(),
      createdAt: a.datetime(),
      updatedAt: a.datetime(),
    })
    .authorization((allow) => [
      allow.owner().to(['create', 'read', 'update', 'delete']),
    ]),
});

export type Schema = ClientSchema<typeof schema>;

export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'identityPool',
  },
});

/*== STEP 2 ===============================================================
Go to your frontend source code. From your client-side code, generate a
Data client to make CRUDL requests to your table. (THIS SNIPPET WILL ONLY
WORK IN THE FRONTEND CODE FILE.)

Using JavaScript or Next.js React Server Components, Middleware, Server 
Actions or Pages Router? Review how to generate Data clients for those use
cases: https://docs.amplify.aws/gen2/build-a-backend/data/connect-to-API/
=========================================================================*/

/*
"use client"
import { generateClient } from "aws-amplify/data";
import type { Schema } from "@/amplify/data/resource";

const client = generateClient<Schema>() // use this Data client for CRUDL requests
*/

/*== STEP 3 ===============================================================
Fetch records from the database and use them in your frontend component.
(THIS SNIPPET WILL ONLY WORK IN THE FRONTEND CODE FILE.)
=========================================================================*/

/* For example, in a React component, you can use this snippet in your
  function's RETURN statement */
// const { data: users } = await client.models.User.list()

// return <ul>{users.map(user => <li key={user.id}>{user.username}</li>)}</ul>
