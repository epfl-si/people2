import { Box, TextField } from '@mui/material';
import React from 'react';

type PersonalFormProps = {
	register: ReturnType<typeof useForm>['register'];
};

export default function PersonalForm({ register: PersonalFormProps}) {
	return (
		<Box>
			<TextField placeholder="Website" {...register("website", { required: true})} />
		</Box>
	);
}
