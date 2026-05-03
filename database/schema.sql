CREATE TABLE public.profiles (
  id uuid NOT NULL,
  email text NOT NULL UNIQUE,
  phone_number text UNIQUE,
  created_at timestamp with time zone DEFAULT now(),
  full_name text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.supply_types (
  id integer NOT NULL DEFAULT nextval('supply_types_id_seq'::regclass),
  name USER-DEFINED NOT NULL,
  unit USER-DEFINED NOT NULL,
  CONSTRAINT supply_types_pkey PRIMARY KEY (id)
);
CREATE TABLE public.devices (
  id integer NOT NULL DEFAULT nextval('devices_id_seq'::regclass),
  name text NOT NULL,
  supply_type_id integer,
  user_id uuid,
  icon_name text,
  CONSTRAINT devices_pkey PRIMARY KEY (id),
  CONSTRAINT devices_supply_type_id_fkey FOREIGN KEY (supply_type_id) REFERENCES public.supply_types(id),
  CONSTRAINT devices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.readings (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  supply_type_id integer NOT NULL,
  value numeric NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  device_id integer NOT NULL,
  CONSTRAINT readings_pkey PRIMARY KEY (id),
  CONSTRAINT readings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT readings_supply_type_id_fkey FOREIGN KEY (supply_type_id) REFERENCES public.supply_types(id),
  CONSTRAINT readings_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id)
);
CREATE TABLE public.alerts (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  title text NOT NULL,
  description USER-DEFINED NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  supply_type_id integer,
  device_id bigint,
  CONSTRAINT alerts_pkey PRIMARY KEY (id),
  CONSTRAINT alerts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT alerts_supply_type_id_fkey FOREIGN KEY (supply_type_id) REFERENCES public.supply_types(id),
  CONSTRAINT alerts_device_id_fkey FOREIGN KEY (device_id) REFERENCES public.devices(id)
);
CREATE TABLE public.supply_status (
  user_id uuid NOT NULL,
  supply_type_id integer NOT NULL,
  is_on boolean DEFAULT false,
  device_id integer NOT NULL,
  CONSTRAINT supply_status_pkey PRIMARY KEY (user_id, device_id),
  CONSTRAINT supply_status_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT supply_status_supply_type_id_fkey FOREIGN KEY (supply_type_id) REFERENCES public.supply_types(id)
);
CREATE TABLE public.feedback (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL UNIQUE,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT feedback_pkey PRIMARY KEY (id),
  CONSTRAINT feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
