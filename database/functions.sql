-- Función para crear el perfil automáticamente al registrarse
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, created_at)
    VALUES (new.id, new.email, new.created_at);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para detectar anomalías y gestionar estados (Nombre actualizado)
CREATE OR REPLACE FUNCTION public.check_reading_anomalies()
RETURNS TRIGGER AS $$
DECLARE
    device_name TEXT;
    was_on BOOLEAN;
    is_now_on BOOLEAN;
BEGIN
    SELECT name INTO device_name FROM public.devices WHERE id = NEW.device_id;
    SELECT is_on INTO was_on FROM public.supply_status
    WHERE user_id = NEW.user_id AND device_id = NEW.device_id;

    is_now_on := (NEW.value > 0);

    -- Detección de fugas
    IF (NEW.supply_type_id = 2 AND NEW.value > 20) OR
       (NEW.supply_type_id = 3 AND NEW.value > 2) OR
       (NEW.supply_type_id = 1 AND NEW.value > 3.5) THEN

        IF NOT EXISTS (
            SELECT 1 FROM public.alerts
            WHERE user_id = NEW.user_id
              AND description = 'Possible leak detected'
              AND is_read = FALSE
              AND title LIKE device_name || '%'
              AND created_at > NOW() - INTERVAL '30 minutes'
        ) THEN
            INSERT INTO public.alerts (user_id, title, description, supply_type_id, device_id)
            VALUES (NEW.user_id, device_name, 'Possible leak detected', NEW.supply_type_id, NEW.device_id);
        END IF;
    END IF;

    -- Gestión ON/OFF
    IF was_on IS NULL THEN
        INSERT INTO public.supply_status (user_id, supply_type_id, device_id, is_on)
        VALUES (NEW.user_id, NEW.supply_type_id, NEW.device_id, is_now_on);
        IF is_now_on THEN
            INSERT INTO public.alerts (user_id, title, description, supply_type_id, device_id)
            VALUES (NEW.user_id, device_name, 'Device left On', NEW.supply_type_id, NEW.device_id);
        END IF;
    ELSIF was_on != is_now_on THEN
        UPDATE public.supply_status SET is_on = is_now_on
        WHERE user_id = NEW.user_id AND device_id = NEW.device_id;
        IF is_now_on THEN
            INSERT INTO public.alerts (user_id, title, description, supply_type_id, device_id)
            VALUES (NEW.user_id, device_name, 'Device left On', NEW.supply_type_id, NEW.device_id);
        ELSE
            INSERT INTO public.alerts (user_id, title, description, supply_type_id, device_id)
            VALUES (NEW.user_id, device_name, 'Device left Off', NEW.supply_type_id, NEW.device_id);
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;