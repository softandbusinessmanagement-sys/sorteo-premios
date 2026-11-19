# Gira y gana

Aplicación estática para registrar participantes mediante un formulario, compartir el enlace con un código QR y sortear ganadores.

## Configurar Supabase

1. Crea un proyecto en Supabase.
2. En **SQL Editor**, ejecuta [`supabase/schema.sql`](./supabase/schema.sql).
3. En **Authentication → Providers → Email**, desactiva el registro público de usuarios.
4. Crea el usuario del organizador desde **Authentication → Users**.
5. Copia el UUID de esa cuenta y autorízala en **SQL Editor**:

   ```sql
   insert into public.sorteo_admins (user_id)
   values ('UUID-DE-LA-CUENTA-DEL-ORGANIZADOR');
   ```

6. Copia la URL del proyecto y la clave pública `anon`/`publishable` desde **Project Settings → API**.
   No uses ni compartas la `service_role` key: esa clave secreta no debe estar en el navegador, Vercel o el repositorio.

La política de seguridad permite que el público solo inserte registros. Leer, actualizar o borrar participantes requiere iniciar sesión con una cuenta autorizada en `sorteo_admins`. Las políticas de la base de datos siguen protegiendo los datos aunque alguien llame directamente a la API.

## Desplegar en Vercel

Importa el repositorio de GitHub en Vercel. [`vercel.json`](./vercel.json) define el build (`npm run build`) y la carpeta de salida (`dist`). Añade estas variables para Production y Preview:
  - `SUPABASE_URL`: URL del proyecto Supabase.
  - `SUPABASE_ANON_KEY`: clave pública `anon` o `publishable` del proyecto.

Vercel genera `dist/config.js` en cada build; las claves públicas son visibles en el navegador por diseño. Nunca añadas una clave `service_role` a las variables del sitio.

Después del despliegue, abre el dominio de Vercel para administrar el sorteo. Comparte el QR del panel con los participantes; sus registros se guardan en Supabase y aparecen en el panel automáticamente.

Para validar la compilación local:

```sh
SUPABASE_URL=https://tu-proyecto.supabase.co SUPABASE_ANON_KEY=tu-clave-publica npm run build
```
